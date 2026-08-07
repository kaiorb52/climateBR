#' Municipality Database
#'
#' @format A data frame with the following variables:
#' \describe{
#'   \item{state}{Brazilian state abbreviation.}
#'   \item{code_ibge7}{Seven-digit IBGE municipality code.}
#'   \item{code_ibge6}{Six-digit IBGE municipality code.}
#'   \item{code_tse}{Six-digit IBGE municipality code.}
#'   \item{lat}{Municipality Centroid Latitude in decimal degrees (WGS84).}
#'   \item{lon}{Municipality Centroid Longitude in decimal degrees (WGS84).}
#' }
#'
#' @examples
#' data(municipality)
#' head(municipality)
#' 
"municipality"