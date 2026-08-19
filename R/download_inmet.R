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
#' @param progress Logical. 
#' Should a progress bar be displayed while the INMET files are being processed? 
#' Defaults to `TRUE`. Set to `FALSE` to disable the progress bar.
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
#' \donttest{
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

