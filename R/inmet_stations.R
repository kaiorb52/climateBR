#' INMET rainfall monitoring stations
#'
#' Dataset containing metadata for rainfall monitoring stations operated by the
#' Brazilian National Institute of Meteorology (INMET). Each row is one
#' station, compiled from INMET data from 2000 to 2026.
#'
#' The dataset includes the station identifier, state, location, and the
#' first and last years with available data for each station.
#'
#' @format A data frame with 700 rows and 6 variables:
#' \describe{
#'   \item{state_station}{Brazilian state abbreviation.}
#'   \item{code_wmo}{WMO station identifier.}
#'   \item{lat}{Station latitude in decimal degrees (WGS84).}
#'   \item{lon}{Station longitude in decimal degrees (WGS84).}
#'   \item{creation_year}{First year with available observations for the station.}
#'   \item{last_used_year}{Last year with available observations for the station. `NA` if
#'   the station is still active.}
#' }
#'
#' @source Instituto Nacional de Meteorologia (INMET).
#'
#' @examples
#' data(inmet_stations)
#' head(inmet_stations)
#'
"inmet_stations"
