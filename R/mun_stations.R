#' Nearest INMET Weather Stations for Brazilian Municipalities
#'
#' A dataset containing the five nearest INMET weather stations for each
#' Brazilian municipality based on the distance between the municipality
#' centroid and the station location.
#'
#' Distances were calculated using the Haversine formula. Each municipality
#' is associated with its five closest INMET stations, ordered by increasing
#' distance.
#'
#' @format A tibble with 27,850 rows and 5 variables:
#' \describe{
#'   \item{state_muni}{Brazilian state abbreviation.}
#'   \item{code_ibge7}{Seven-digit IBGE municipality code.}
#'   \item{code_wmo}{World Meteorological Organization (WMO) identifier of the
#'   INMET weather station.}
#'   \item{distance}{Distance between the municipality centroid and the station,
#'   in kilometers.}
#'   \item{station_order}{Rank of the station by proximity, where 1 indicates
#'   the nearest station.}
#' }
#' 
#' @details
#' The dataset was generated with [nearest_stations()], matching each
#' municipality centroid to the five closest stations in the
#' `inmet_stations` dataset.
#'
#' It reflects the most recent INMET station network and is intended for
#' analyses of recent observations. Because stations are added and removed
#' over time, do not use it to match data from earlier years. For historical
#' analyses, use `mun_stations_distance` or build a year-specific mapping
#' with [nearest_stations()] and the station network of that year.
#'
#' @source
#' Distances were computed from municipality centroid coordinates and INMET
#' station coordinates using the Haversine formula.
#' 
#' @examples
#' data(mun_stations)
#' head(mun_stations)
"mun_stations"