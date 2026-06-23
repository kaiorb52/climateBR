#' INMET rainfall monitoring stations by year
#'
#' Dataset containing metadata for rainfall monitoring stations operated by the
#' Brazilian National Institute of Meteorology (INMET). Each row represents a
#' meteorological station in a specific year between 2000 and 2024.
#'
#' The dataset includes station identifiers, location information, state,
#' municipality codes, and the first and last years in which data are available
#' for each station.
#'
#' @format A data frame with 9,459 rows and 11 variables:
#' \describe{
#'   \item{uf}{Brazilian state abbreviation.}
#'   \item{estacao}{Name of the meteorological station.}
#'   \item{codigo_wmo}{WMO station identifier.}
#'   \item{ano}{Reference year.}
#'   \item{nome_formatado}{Standardized station name.}
#'   \item{frist_year}{First year with available observations for the station.}
#'   \item{last_year}{Last year with available observations for the station.}
#'   \item{id_ibge7}{Seven-digit IBGE municipality code.}
#'   \item{id_tse}{Municipality code used by the Brazilian Electoral Court (TSE).}
#'   \item{latitude}{Latitude in decimal degrees (WGS84).}
#'   \item{longitude}{Longitude in decimal degrees (WGS84).}
#' }
#'
#' @source Instituto Nacional de Meteorologia (INMET).
#'
#' @examples
#' head(rain_stations)
#' unique(rain_stations$ano)
#'
"rain_stations"
