#' Download historical meteorological data from INMET
#'
#' Downloads historical weather station data from the Brazilian National
#' Institute of Meteorology (INMET) and extracts the downloaded ZIP files
#' into a user-specified directory.
#'
#' @param years Integer vector specifying the years to download.
#'   Historical data are available from 2000 onwards. The default is
#'   `2008`.
#' @param unzip_to Character. Directory where the downloaded files will
#'   be extracted.
#' @param progress Logical. If `TRUE` (default), displays a progress bar
#'   while downloading the INMET files.
#' 
#' @details
#' INMET provides historical observations dating back to 2000. However,
#' only a small number of weather stations were operating in the early
#' years of the dataset. For most applications, we recommend using data
#' from **2008 onwards**, when the monitoring network became substantially
#' more comprehensive.
#'
#' Existing directories containing extracted files are skipped to avoid
#' downloading the same data multiple times.
#'
#' The downloaded files can subsequently be processed with
#' [build_inmet_dataset()].
#'
#' @return
#' This function is called for its side effects. ZIP files are downloaded,
#' extracted into `unzip_to`, and the extracted files are stored on disk.
#'
#' @seealso
#' [build_inmet_dataset()], [read_inmet()]
#'
#' @examples
#' \dontrun{
#'
#' ## Download a single year
#' download_inmet(
#'   years = 2000,
#'   unzip_to = tempdir()
#' )
#'
#' ## Download multiple years
#' download_inmet(
#'   years = 2004:2006,
#'   unzip_to = tempdir()
#' )
#'
#' }
#'
#' @import glue
#' @importFrom utils download.file unzip txtProgressBar setTxtProgressBar
#' @export

download_inmet <- function(years = 2008, unzip_to = tempdir(), progress = TRUE){

  old_options <- options(timeout = max(getOption("timeout"), 600))
  on.exit(options(old_options), add = TRUE)
  
  if (progress == TRUE){
    pb <- txtProgressBar(min = 0, max = length(years), style = 3)
  }
  
  i <- 0
  for (x in years){
    i = i + 1
    url_year <- glue("https://portal.inmet.gov.br/uploads/dadoshistoricos/{x}.zip")
    unzip_complete <- glue("{unzip_to}/{x}/")

    temp_path <- file.path(tempdir(), glue("inmet_{x}.zip"))

    if (check_file(unzip_complete)){

      if (length(list.files(unzip_complete)) >= 5){
        if (progress == TRUE){
          setTxtProgressBar(pb, i)
        }
        next
      }

    }
    
    status <- tryCatch(
      {
        download.file(
          url = url_year,
          destfile = temp_path,
          quiet = TRUE
        )
        TRUE
      },
      error = function(e) {
        warning(
          sprintf("Failed to download data for %s.", x),
          call. = FALSE
        )
        FALSE
      }
    )
    
    if (!status) {
      if (progress == TRUE){
        setTxtProgressBar(pb, i)
      }
      next
    }
    
    unzip(
      zipfile = temp_path,
      exdir   = unzip_complete,
      overwrite = TRUE,
      junkpaths = TRUE
    )
    
    if (progress == TRUE){
      setTxtProgressBar(pb, i)
    }
    
  }
  
  if (progress == TRUE){
    close(pb)
  }
  
}


#' Read INMET meteorological observations
#'
#' Reads an INMET dataset previously created with
#' [build_inmet_dataset()]. The dataset is accessed through
#' the Arrow Dataset interface, allowing efficient filtering
#' without loading all observations into memory.
#'
#' @param path Character. Path to the directory containing the
#'   processed INMET dataset.
#' @param years Integer vector of years to read. If `NULL`,
#'   all available years are returned.
#' @param stations Character vector of WMO station codes. If
#'   `NULL`, all stations are returned.
#' @param variables Character vector of variables (columns) to
#'   return. If `NULL`, all variables are returned.
#' @param collect Logical. If `TRUE`, the filtered dataset is
#'   collected into memory as a data frame. If `FALSE` (default),
#'   an Arrow Dataset query is returned.
#'
#' @details
#' The function performs filtering directly on disk whenever
#' possible, making it suitable for working with large datasets.
#'
#' Setting `collect = TRUE` loads the selected observations into
#' memory. This may require a large amount of RAM when reading
#' many years or stations at once. Filter by year, station, or
#' variable before collecting the data.
#'
#' @return
#' If `collect = FALSE`, returns an Arrow Dataset query.
#' If `collect = TRUE`, returns a data frame containing the
#' selected observations.
#' 
#' @examples
#' # Requires INMET data downloaded with download_inmet() and
#' # processed into an Arrow dataset with build_inmet_dataset().
#' # See the vignette "climateBR: An R package to download meteorological
#' # data from Brazil" for the complete workflow.
#' 
#' \dontrun{
#' 
#' ## Read a single year without loading the data into memory
#' rainfall_df1 <- read_inmet(
#'   path = dataset_dir,
#'   years = 2000,
#'   collect = FALSE
#' )
#'
#' ## Read multiple years and collect the results into memory
#' rainfall_df2 <- read_inmet(
#'   path = dataset_dir,
#'   years = 2000:2005,
#'   collect = TRUE
#' )
#'
#' ## For large datasets, keeping collect = FALSE is generally
#' ## recommended to avoid excessive memory usage.
#' }
#'  
#' @seealso
#' [download_inmet()], [build_inmet_dataset()]
#'
#' @importFrom rlang .data
#' @export

read_inmet <- function(
    path = NULL,
    years = NULL,
    stations = NULL,
    variables = NULL,
    collect = FALSE
) {
  
  ds <- arrow::open_dataset(path)
  
  if (!is.null(years))
    ds <- dplyr::filter(
      ds,
      .data$ano %in% years
    )
  
  if (!is.null(stations))
    ds <- dplyr::filter(
      ds,
      .data$codigo_wmo %in% stations
    )
  
  if (!is.null(variables))
    ds <- dplyr::select(
      ds,
      dplyr::all_of(variables)
    )
  
  if (collect)
    dplyr::collect(ds)
  else
    ds
}

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
#' \dontrun{
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
