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
      dplyr::select(codigo_wmo)
    
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
