#' Rainfall during the 2024 Rio Grande do Sul floods
#'
#' Dataset containing accumulated rainfall observed at meteorological stations
#' operated by the Brazilian National Institute of Meteorology (INMET) during
#' the extreme flooding event that affected Rio Grande do Sul, Brazil, in 2024.
#' 
#' The dataset contains 545 monitoring stations distributed across Brazil.
#' Each row corresponds to a single INMET weather station and includes its
#' identification code, geographic coordinates, and the total accumulated
#' rainfall (in millimeters) recorded between April 27 and May 5, 2024.
#'
#' @format A data frame with 545 rows and 4 variables:
#' \describe{
#'   \item{id_who}{Character. INMET weather station identifier.}
#'   \item{lat}{Numeric. Latitude of the station in decimal degrees (WGS84).}
#'   \item{long}{Numeric. Longitude of the station in decimal degrees (WGS84).}
#'   \item{total_rainfall}{Numeric. Total accumulated rainfall (mm) during the study period.}
#' }
#'
#' @source Brazilian National Institute of Meteorology (INMET).
#'
#' @examples
#' head(floods_rs)
#' summary(floods_rs$total_rainfall)
#'
"floods_rs"