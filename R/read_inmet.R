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
#' many years or stations simultaneously. Consider filtering by
#' year, station, or variables before collecting the data.
#'
#' @return
#' If `collect = FALSE`, returns an Arrow Dataset query.
#' If `collect = TRUE`, returns a data frame containing the
#' selected observations.
#' 
#' @examples
#' \dontrun{
#'
#' ## Read a single year without loading the data into memory
#' rainfall_df1 <- read_inmet(
#'   path = "~/inmet",
#'   years = 2008,
#'   collect = FALSE
#' )
#'
#' ## Read multiple years and collect the results into memory
#' rainfall_df2 <- read_inmet(
#'   path = "~/inmet",
#'   years = 2008:2012,
#'   collect = TRUE
#' )
#'
#' ## For large datasets, keeping `collect = FALSE` is generally
#' ## recommended to avoid excessive memory usage.
#'
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