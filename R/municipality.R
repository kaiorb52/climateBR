#' Brazilian municipalities
#'
#' Dataset with the IBGE and TSE codes, state, and centroid coordinates of
#' each Brazilian municipality.
#'
#' @format A data frame with 5,570 rows and 6 variables:
#' \describe{
#'   \item{state_muni}{Brazilian state abbreviation.}
#'   \item{code_ibge7}{Seven-digit IBGE municipality code.}
#'   \item{code_ibge6}{Six-digit IBGE municipality code.}
#'   \item{code_tse}{Municipality code used by the Brazilian Superior Electoral
#'   Court (TSE).}
#'   \item{lat}{Latitude of the municipality centroid in decimal degrees (WGS84).}
#'   \item{lon}{Longitude of the municipality centroid in decimal degrees (WGS84).}
#' }
#'
#' @examples
#' data(municipality)
#' head(municipality)
#' 
"municipality"