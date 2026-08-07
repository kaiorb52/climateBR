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
#' @format A tibble with 27,850 rows and 4 variables:
#' \describe{
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
#' The dataset was generated using the `nearest_stations()` function from the
#' climateBR package, matching municipality centroids to the five closest INMET
#' weather stations available in the package's `inmet_stations` dataset.
#'
#' This dataset is based on the most recent version of the INMET station
#' network available in the package. It is intended for analyses using recent
#' observations. Because the INMET network changes over time (stations may be
#' added or removed), this dataset should not be used to match
#' historical data from earlier years. For historical analyses, users should
#' create a year-specific municipality-to-station mapping using the
#' corresponding historical INMET station 
#' 
#' @source
#' Distances were computed from municipality centroid coordinates and INMET
#' station coordinates using the Haversine formula.
#' 
#' @examples
#' data(mun_stations)
#' head(mun_stations)
"mun_stations"