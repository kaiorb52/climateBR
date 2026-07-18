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
#' \dontrun{
#'
#' build_inmet_dataset(
#'   input = "~/Downloads/inmet",
#'   output = "~/data/inmet"
#' )
#'
#' }
#' 
#' @importFrom rlang .data
#'
#' @export

build_inmet_dataset <- function(input, output) {
  
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  
  files <- list.files(
    input,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "\\.CSV$"
  )
  
  for (x in files) {
    
    message(basename(x))
    
    meta <-
      data.table::fread(x, nrows = 6) |>
      tidyr::pivot_wider(
        names_from = 1,
        values_from = 2
      ) |>
      janitor::clean_names() |>
      dplyr::select(.data$codigo_wmo)
    
    df <-
      data.table::fread(
        x,
        skip = 7,
        sep = ";",
        encoding = "Latin-1"
      ) |>
      janitor::clean_names()
    
    df[3:19] <-
      lapply(
        df[3:19],
        \(z)
        as.numeric(
          gsub(",", ".", z)
        )
      )
    
    ano <-
      as.integer(
        basename(dirname(x))
      )
    
    df <-
      dplyr::cross_join(
        meta,
        df
      ) |>
      dplyr::mutate(
        ano = ano
      )
    
    if ("data" %in% names(df))
      names(df)[names(df) == "data"] <- "data_yyyy_mm_dd"
    
    arrow::write_dataset(
      df,
      output,
      partitioning = c("ano","codigo_wmo"),
      existing_data_behavior = "overwrite"
    ) 
  }
  
  invisible(output)
}
