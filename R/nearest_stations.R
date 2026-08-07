#' Find the nearest INMET stations for each municipality
#'
#' Computes the great-circle distance between each municipality and all INMET
#' stations, returning the `n` nearest stations for every municipality.
#'
#' @param municipality A data frame containing the municipality coordinates.
#'   Must include the columns `code_ibge7`, `lat`, and `lon`.
#' @param inmet_stations A data frame containing the INMET station coordinates.
#'   Must include the columns `code_wmo`, `lat`, and `lon`.
#' @param n Number of nearest stations to return for each municipality.
#'
#' @return
#' A tibble with the columns:
#' \describe{
#'   \item{code_ibge7}{Municipality code.}
#'   \item{code_wmo}{INMET station code.}
#'   \item{distance}{Distance (in meters) between the municipality and station.}
#'   \item{station_order}{}
#' }
#'
#' @export


nearest_stations <- function(
    municipality,
    inmet_stations,
    n = 5
) {
  stations_list <- inmet_stations |>
    dplyr::transmute(
      code_wmo = .data$code_wmo,
      coord = purrr::map2(.data$lat, .data$lon, c)
    ) |>
    tibble::deframe()
  
  municipality |>
    dplyr::transmute(
      code_ibge7 = .data$code_ibge7,
      mun_coord = purrr::map2(.data$lat, .data$lon, c)
    ) |>
    dplyr::mutate(
      distances = purrr::map(
        .data$mun_coord,
        \(coord) {
          tibble::tibble(
            code_wmo = names(stations_list),
            distance = purrr::map_dbl(
              stations_list,
              \(station) pracma::haversine(coord, station)
            )
          )
        }
      )
    ) |>
    tidyr::unnest(.data$distances) |>
    dplyr::select(-.data$mun_coord) |>
    dplyr::arrange(.data$code_ibge7, .data$distance) |>
    dplyr::group_by(.data$code_ibge7) |>
    dplyr::mutate(
      station_order = dplyr::row_number()
    ) |>
    dplyr::filter(.data$station_order <= n) |>
    dplyr::ungroup()
}