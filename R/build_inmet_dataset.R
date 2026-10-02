#' Build a partitioned Arrow dataset from INMET CSV files
#'
#' Converts the raw CSV files downloaded from INMET into a partitioned
#' Arrow/Parquet dataset optimized for fast querying with
#' [read_inmet()].
#'
#' During the conversion, metadata are extracted from each file,
#' column names are standardized, numeric variables are converted to
#' numeric format, and the resulting dataset is partitioned (by default)
#' by year (`ano`) and WMO station code (`codigo_wmo`).
#'
#' @param input Character. Directory containing the raw CSV files
#'   downloaded with [download_inmet()].
#' @param output Character. Directory where the partitioned
#'   Arrow/Parquet dataset will be written.
#' @param years Integer vector. Years of INMET data in `input` to convert
#'   into the Arrow/Parquet dataset. Defaults to `2000:2026`.
#' @param partitioning_by Character vector. Variable(s) used to partition
#'   the dataset; each variable creates one level of Parquet folders.
#'   Defaults to `c("ano", "codigo_wmo")`.
#' @param region Character vector. INMET region abbreviation(s) to filter
#'   (e.g. `"NE"`, `"SE"`). Defaults to `"all"`, which applies no filter.
#' @param state Character vector. Brazilian state abbreviation(s) (`uf`) to
#'   filter (e.g. `"BA"`, `"SP"`). Defaults to `"all"`, which applies no
#'   filter.
#' @param progress Logical. If `TRUE` (default), displays a progress bar
#'   while processing the INMET files.
#' 
#'
#' @details
#' This function only needs to be executed once for a collection of
#' downloaded INMET files. After the dataset has been created, it can
#' be accessed efficiently using [read_inmet()] without repeatedly
#' parsing the original CSV files.
#'
#' With the default partitioning by year (`ano`) and weather station
#' (`codigo_wmo`), Arrow reads only the files required by a query.
#'
#' @return
#' Invisibly returns the output directory.
#'
#' @seealso
#' [download_inmet()], [read_inmet()]
#'
#' @examples
#' \donttest{
#'
#' build_inmet_dataset(
#'   input = file.path(tempdir(), "inmet_raw"),
#'   output = file.path(tempdir(), "inmet_arrow"),
#'   progress = FALSE
#' )
#'
#' }
#' 
#' @importFrom rlang .data
#' @importFrom utils txtProgressBar setTxtProgressBar
#'
#' @export

build_inmet_dataset <- function(input, output, years = 2000:2026, partitioning_by = c("ano", "codigo_wmo"), region = "all", state = "all", progress = TRUE) {

  dir.create(output, recursive = TRUE, showWarnings = FALSE)

  files <- list.files(
    input,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "\\.CSV$"
  )

  files <- files[basename(dirname(files)) %in% as.character(years)]

  name_parts <- strsplit(basename(files), "_")
  file_region <- vapply(name_parts, `[`, character(1), 2)
  file_state <- vapply(name_parts, `[`, character(1), 3)

  keep <- rep(TRUE, length(files))

  if (!identical(region, "all"))
    keep <- keep & file_region %in% toupper(region)

  if (!identical(state, "all"))
    keep <- keep & file_state %in% toupper(state)

  files <- files[keep]

  if (length(files) == 0)
    stop(
      sprintf(
        "No files found for region = %s and state = %s. Check if this is a valid combination.",
        paste(region, collapse = ", "),
        paste(state, collapse = ", ")
      ),
      call. = FALSE
    )

  if (progress == TRUE){
    pb <- txtProgressBar(min = 0, max = length(files), style = 3)
  }

  i <- 0
  for (x in files) {

    tryCatch({
    i <- i + 1
    
    name_parts <- strsplit(basename(x), "_")[[1]]
    regiao <- name_parts[2]
    uf <- name_parts[3]

    meta <- data.table::fread(x, nrows = 6, encoding = "Latin-1") |>
      tidyr::pivot_wider(
        names_from = 1,
        values_from = 2
      ) |>
      janitor::clean_names() |>
      dplyr::select(.data$codigo_wmo) |>
      dplyr::mutate(
        regiao = regiao,
        uf = uf
      )

    #txt <- readLines(x, n = 20, encoding = "Latin-1", warn = FALSE)
    #header <- grep("^data[;]|DATA (YYYY-MM-DD)", txt, ignore.case = TRUE)
    #print(header)
    
    df <- data.table::fread(
        x,
        skip = 8,
        header = TRUE,
        sep = ";",
        encoding = "Latin-1",
        na.strings = c("", "-9999", "NA", "NaN")
      ) |>
      janitor::clean_names()
    
    df[3:19] <- lapply(
        df[3:19],
        \(z)
        as.numeric(
          gsub(",", ".", z)
        )
      )
    
    if ("data" %in% names(df))
      names(df)[names(df) == "data"] <- "data_yyyy_mm_dd"
      df$data_yyyy_mm_dd <- as.Date(
      gsub("/", "-", df$data_yyyy_mm_dd)
    )

    df <- df |>
      dplyr::select(-dplyr::matches("^v\\d+$"))
      
    ano <- as.integer(
        basename(dirname(x))
      )
    
    mes <- as.integer(
      format(df$data_yyyy_mm_dd, "%m")
    )
    
    df <- dplyr::cross_join(
        meta,
        df
      ) |>
      dplyr::mutate(
        ano = ano,
        mes = mes
      ) |>
      dplyr::relocate(
        .data$ano, .data$mes, .data$codigo_wmo, .data$regiao, .data$uf,
        .before = 1
      )
    
    arrow::write_dataset(
      df,
      output,
      partitioning = partitioning_by,
      existing_data_behavior = "overwrite"
    ) 
    rm(df)
    invisible(output)

    }, error = function(e) {
      
      # TO-DO ERROR MESSAGE
      
  })
    
    if (progress == TRUE){
      setTxtProgressBar(pb, i)
    }
    
  }
  
  if (progress == TRUE){
    close(pb)
  }
  
}
