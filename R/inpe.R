#' Download fire hotspot data from INPE's Programa Queimadas
#'
#' Downloads the annual records of fire hotspots (*focos de queimada*)
#' detected by satellite over Brazil, made available by the National
#' Institute for Space Research (INPE) through the *Programa Queimadas*.
#' The files include detections from all satellites monitored by INPE.
#'
#' @param years Integer vector specifying the years to download.
#'   Historical data are available from 1998 onwards. The default is
#'   `2025`.
#' @param dest_dir Character. Directory where the files are saved
#'   (e.g. `"./data/raw/"`). It is created if it does not exist. If `NULL`
#'   (default), a temporary directory is used.
#'
#' @details
#' Source: National Institute for Space Research (INPE), *Programa
#' Queimadas*. More information:
#' <https://data.inpe.br/queimadas/portal/dados-abertos/>.
#'
#' The main columns are
#' the hotspot coordinates (`latitude`, `longitude`), the detection time
#' (`data_pas`), the satellite (`satelite`), the location (`pais`, `estado`,
#' `municipio`, `bioma`), and fire-related indicators such as
#' `numero_dias_sem_chuva`, `precipitacao`, `risco_fogo` and `frp`
#' (fire radiative power). The files do not include IBGE municipality
#' codes; to link hotspots to [municipality] or [mun_stations], use the
#' coordinates (e.g. a spatial join with municipality boundaries) or the
#' municipality and state names.
#'
#' The structure of the files has changed over time, so older years may lack
#' some columns (filled with `NA` when several years are combined).
#'
#' Years whose file already exists in `dest_dir` are read from disk instead
#' of being downloaded again. If a file is corrupted (e.g. after an
#' interrupted download), delete it and run the function again.
#'
#' @return
#' A data frame with one row per fire hotspot, combining all requested
#' `years`.
#'
#' @seealso
#' [download_disasters()], [municipality], [mun_stations]
#'
#' @examples
#' \dontrun{
#'
#' ## Download a single year
#' firespots <- download_firespots(years = 2024)
#'
#' ## Download multiple years
#' firespots <- download_firespots(years = 2022:2024)
#'
#' ## Keep the files locally
#' firespots <- download_firespots(years = 2024, dest_dir = "./data/raw/")
#'
#' }
#'
#' @import glue
#' @importFrom utils download.file unzip
#' @export

download_firespots <- function(years = 2025, dest_dir = NULL) {

  old_options <- options(timeout = max(getOption("timeout"), 600))
  on.exit(options(old_options), add = TRUE)

  # https://data.inpe.br/queimadas/portal/dados-abertos/

  base_url <- "https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/focos_br_todos-sats_{y}.zip"

  if (is.null(dest_dir)) {
    dest_dir <- tempfile()
  }
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  csv_paths <- file.path(dest_dir, glue("focos_br_todos-sats_{years}.csv"))
  already <- years[file.exists(csv_paths)]

  if (length(already) > 0) {
    message(
      "Files for ", length(already), " year(s) already exist in '", dest_dir
    )
  }

  list_df <- list()
  for (y in years){
    csv_path <- file.path(dest_dir, glue("focos_br_todos-sats_{y}.csv"))

    if (!check_file(csv_path)) {
      tmp_zip <- tempfile(fileext = ".zip")
      download.file(
        glue(base_url),
        destfile = tmp_zip
      )
      unzip(tmp_zip, overwrite = TRUE, exdir = dest_dir, junkpaths = TRUE)
      unlink(tmp_zip)
    }

    list_df[[as.character(y)]] <- data.table::fread(csv_path)

  }

  return(
    list_df |>
      dplyr::bind_rows()
  )
}
