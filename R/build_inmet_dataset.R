#' Build a partitioned Arrow dataset from INMET CSV files
#'
#' Converts the raw CSV files downloaded from INMET into a partitioned
#' Arrow/Parquet dataset optimized for fast querying with
#' [read_inmet()].
#'
#' During the conversion, metadata are extracted from each file,
#' column names are standardized, numeric variables are converted to
#' numeric format, and the resulting dataset is partitioned by year
#' (`ano`) and WMO station code (`codigo_wmo`).
#'
#' @param input Character. Directory containing the raw CSV files
#'   downloaded with [download_inmet()].
#' @param output Character. Directory where the partitioned
#'   Arrow/Parquet dataset will be written.
#' @param years Vector. Group of years of the INMET database located in `input`
#'   to be transformed into an Arrow/Parquet dataset.
#' @param partitioning_by Vector. Variable(s) in the INMET database used to
#'   create the parquet folders.
#'
#' @details
#' This function only needs to be executed once for a collection of
#' downloaded INMET files. After the dataset has been created, it can
#' be accessed efficiently using [read_inmet()] without repeatedly
#' parsing the original CSV files.
#'
#' The resulting dataset is partitioned by year (`ano`) and weather
#' station (`codigo_wmo`), allowing Arrow to read only the files
#' required by a query.
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
#'   output = file.path(tempdir(), "inmet_arrow")
#' )
#'
#' }
#' 
#' @importFrom rlang .data
#'
#' @export

build_inmet_dataset <- function(input, output, years = 2000:2026, partitioning_by = c("ano", "codigo_wmo")) {
  
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  
  files <- list.files(
    input,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "\\.CSV$"
  )
  
  files <- files[basename(dirname(files)) %in% as.character(years)]
  
  for (x in files) {
    
    tryCatch({
      
    meta <- data.table::fread(x, nrows = 6) |>
      tidyr::pivot_wider(
        names_from = 1,
        values_from = 2
      ) |>
      janitor::clean_names() |>
      dplyr::select(.data$codigo_wmo)
    
    txt <- readLines(x, n = 20, encoding = "UTF-8")
    header <- grep("^data|^DATA", txt)
    
    df <- data.table::fread(
        x,
        skip = header,
        sep = ";",
        encoding = "Latin-1"
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
        .data$ano, .data$mes, .data$codigo_wmo,
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
  }
}
