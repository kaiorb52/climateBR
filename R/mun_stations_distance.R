#' Distance Between Brazilian Municipal Centroids and INMET Rainfall Stations
#'
#' A dataset containing the distances between the centroids of Brazilian
#' municipalities and rainfall stations operated by the Brazilian National
#' Institute of Meteorology (INMET). Distances were computed using the
#' Haversine formula.
#'
#' The dataset covers the period from 2008 to 2024. Because the INMET station
#' network changes over time, distances were calculated for snapshots taken
#' every two years (2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024).
#'
#' Each municipality is associated with all available INMET stations for the
#' corresponding year, ordered by increasing distance. The variable `i`
#' indicates the rank of the station according to its proximity to the
#' municipality centroid.
#'
#' @format A data frame with the following variables:
#' \describe{
#'   \item{code_muni}{Seven-digit IBGE municipality code.}
#'   \item{codigo_wmo}{WMO identifier of the INMET rainfall station.}
#'   \item{distance}{Distance between the municipality centroid and the station,
#'   in kilometers.}
#'   \item{i}{Rank of the station by distance, where 1 indicates the nearest
#'   station.}
#'   \item{ano}{Reference year (2008, 2010, ..., 2024).}
#' }
#'
#' @source Distances computed from municipality centroids and INMET rainfall
#' station coordinates using the Haversine formula.
#'
#' @examples
#' data(mun_stations_distance)
#' head(mun_stations_distance)
"mun_stations_distance"