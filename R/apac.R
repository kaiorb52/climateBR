#' Download historical rainfall data from APAC (Pernambuco)
#'
#' Downloads the historical monthly rainfall records published by
#' Pernambuco's Water and Climate Agency (APAC) on its rainfall monitoring
#' portal, for one or more of the state's mesoregions.
#'
#' @param years Integer vector specifying the years to download.
#'   Historical data are available from 1961 onwards. The default is
#'   `2025`.
#' @param mesoregions Integer vector of IBGE mesoregion codes to download.
#'   The default is all five mesoregions of Pernambuco: `2601` (Sertão
#'   Pernambucano), `2602` (São Francisco Pernambucano), `2603` (Agreste
#'   Pernambucano), `2604` (Mata Pernambucana) and `2605` (Metropolitana do
#'   Recife).
#' @param dest_dir Character. Directory where the CSV files are saved
#'   (e.g. `"./data/raw/"`). It is created if it does not exist. If `NULL`
#'   (default), files are saved to a temporary directory and discarded at
#'   the end of the R session.
#' @param progress Logical. If `TRUE` (default), displays a progress bar
#'   while querying APAC.
#'
#' @details
#' APAC's portal
#' (<http://old.apac.pe.gov.br/meteorologia/monitoramento-pluvio.php>)
#' renders its results table dynamically with JavaScript, so there is no
#' static file to download. Instead, a headless Chrome session is driven
#' through the \pkg{chromote} package to query each mesoregion/year, and
#' the results table is parsed with \pkg{rvest}. This requires a local
#' installation of Google Chrome or Chromium, and the \pkg{chromote} and
#' \pkg{rvest} packages.
#'
#' Each mesoregion/year is saved to `dest_dir` as `apac_{mesoregion}_{year}.csv`.
#' Files that already exist in `dest_dir` are read from disk instead of
#' being queried again. Queries that fail raise a warning and are skipped.
#'
#' Column names are kept as distributed by the source (e.g. `Código`,
#' `Posto`, `Mês/Ano`), plus `cod_mesorregiao` and `ano`.
#'
#' @return
#' A data frame with one row per rain gauge and month, combining all
#' requested `years` and `mesoregions`.
#'
#' @seealso
#' [download_inmet()], [download_firespots()], [download_disasters()]
#'
#' @examples
#' \dontrun{
#'
#' ## Download a single year for the Metropolitan Region of Recife
#' apac <- download_apac(years = 2020, mesoregions = 2605)
#'
#' ## Download multiple years for all mesoregions, keeping the CSV files
#' apac <- download_apac(years = 2020:2024, dest_dir = "./data/raw/")
#'
#' }
#'
#' @import glue
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @export

download_apac <- function(years = 2025, mesoregions = 2601:2605, dest_dir = NULL, progress = TRUE) {

  if (!requireNamespace("chromote", quietly = TRUE) || !requireNamespace("rvest", quietly = TRUE)) {
    stop(
      "Packages \"chromote\" and \"rvest\" are required to download APAC data. ",
      "Install them with install.packages(c(\"chromote\", \"rvest\")).",
      call. = FALSE
    )
  }

  # Chrome may take longer than chromote's default 10s to start
  old_options <- options(chromote.timeout = 60)
  on.exit(options(old_options), add = TRUE)

  base_url <- "http://old.apac.pe.gov.br/meteorologia/monitoramento-pluvio.php"

  if (is.null(dest_dir)) {
    dest_dir <- tempfile()
  }
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  b <- NULL

  if (progress == TRUE){
    pb <- txtProgressBar(min = 0, max = length(mesoregions) * length(years), style = 3)
  }

  i <- 0
  list_df <- list()
  for (meso in mesoregions){
    for (y in years){
      i <- i + 1
      csv_path <- file.path(dest_dir, glue("apac_{meso}_{y}.csv"))

      if (!check_file(csv_path)) {

        if (is.null(b)) {
          b <- chromote::ChromoteSession$new()
          on.exit(try(b$close(), silent = TRUE), add = TRUE)
          # Accept JS alerts (e.g. invalid date range) so they don't block the page
          b$Page$javascriptDialogOpening(function(...) {
            try(b$Page$handleJavaScriptDialog(accept = TRUE), silent = TRUE)
          })
        }

        df <- tryCatch(
          apac_query(b, base_url, meso, y),
          error = function(e) {
            warning(
              sprintf("Failed to query APAC data for %s/%s.", meso, y),
              call. = FALSE
            )
            NULL
          }
        )

        if (!is.null(df) && nrow(df) > 0) {
          df$cod_mesorregiao <- meso
          df$ano <- y
          data.table::fwrite(df, csv_path)
        }
      }

      if (check_file(csv_path)) {
        list_df[[glue("{meso}_{y}")]] <- data.table::fread(csv_path, encoding = "UTF-8")
      }

      if (progress == TRUE){
        setTxtProgressBar(pb, i)
      }
    }
  }

  if (progress == TRUE){
    close(pb)
  }

  return(
    list_df |>
      dplyr::bind_rows()
  )
}

# Queries one mesoregion/year on APAC's portal; returns an empty data frame on timeout.
apac_query <- function(b, base_url, meso, y) {

  # Reload the page so the results table of a previous query is gone
  b$Page$navigate(base_url)
  b$Page$loadEventFired()
  Sys.sleep(5)

  d_ini <- glue("01/01/{y}")
  d_fim <- min(as.Date(glue("{y}-12-31")), Sys.Date()) |> format("%d/%m/%Y")

  b$Runtime$evaluate(glue(
    "
    (function() {{
      var sel = document.getElementById('pmesorregiao');
      Array.prototype.forEach.call(sel.options, function(opt) {{
        opt.selected = (opt.value === '{meso}');
      }});
      sel.dispatchEvent(new Event('change', {{ bubbles: true }}));

      var ini = document.getElementById('dataInicial');
      var fim = document.getElementById('dataFinal');
      ini.value = '{d_ini}';
      fim.value = '{d_fim}';
      ['change', 'input', 'blur'].forEach(function(evt) {{
        ini.dispatchEvent(new Event(evt, {{ bubbles: true }}));
        fim.dispatchEvent(new Event(evt, {{ bubbles: true }}));
      }});

      document.getElementById('btPesquisaPluvio').click();
    }})();
    "
  ))

  start <- Sys.time()
  while (difftime(Sys.time(), start, units = "secs") < 120) {
    Sys.sleep(1)

    html <- b$Runtime$evaluate(
      "(function() { var t = document.getElementById('tbMonPluvio'); return t ? t.outerHTML : null; })();",
      returnByValue = TRUE
    )$result$value

    if (is.null(html)) next

    df <- rvest::html_table(rvest::read_html(html), header = TRUE)[[1]]

    if (all(c("C\u00f3digo", "Posto", "M\u00eas/Ano") %in% names(df)) &&
        any(grepl(y, df[["M\u00eas/Ano"]], fixed = TRUE))) {
      df[["C\u00f3digo"]] <- suppressWarnings(as.integer(df[["C\u00f3digo"]]))
      return(as.data.frame(df[!is.na(df[["C\u00f3digo"]]), ]))
    }
  }

  warning(sprintf("Timeout: no APAC data loaded for %s/%s.", meso, y), call. = FALSE)
  data.frame()
}
