
#' @import glue
#' @importFrom utils download.file unzip
#' @export

#############################################################################
#############################################################################

download_inmet <- function(years = 2008, unzip_to = getwd()){

  options(timeout = Inf)
  check_dir(path = unzip_to)

  for (x in years){

    if (!x %in% years){
      print(glue("Data not avaliable for {x} year."))
      next
    }

    url_year <- glue("https://portal.inmet.gov.br/uploads/dadoshistoricos/{x}.zip")
    unzip_complete <- glue("{unzip_to}/{x}/")

    temp_path <- file.path(tempdir(), glue("inmet_{x}.zip"))

    if (check_file(unzip_complete)){

      if (length(list.files(unzip_complete)) >= 5){
        next
      }

    }

    message("Download From:\n", url_year)

    download.file(
      url      = url_year,
      destfile = temp_path
    )

    unzip(
      zipfile = temp_path,
      exdir   = unzip_complete,
      overwrite = TRUE,
      junkpaths = TRUE
    )

  }
}

