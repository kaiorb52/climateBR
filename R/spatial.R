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
#'   \item{state_muni}{Brazilian state abbreviation.}
#'   \item{code_ibge7}{Seven-digit IBGE municipality code.}
#'   \item{code_wmo}{WMO identifier of the INMET station.}
#'   \item{distance}{Distance (in kilometers) between the municipality and the station.}
#'   \item{station_order}{Rank of the station by distance, where 1 indicates the nearest
#'   station.}
#' }
#'
#' @examples
#'
#' data("municipality")
#' data("inmet_stations")
#'
#' mun_rs <- municipality[municipality$state_muni == "RS", ]
#'
#' mun_stations1 <- nearest_stations(
#'   municipality = mun_rs,
#'   inmet_stations = inmet_stations,
#'   n = 1
#' )
#'
#' # Stations from other states may be returned. This is expected:
#' # municipalities near state borders may be closer to a station in a
#' # neighboring state.
#'
#' mun_stations2 <- nearest_stations(
#'   municipality = mun_rs,
#'   inmet_stations = inmet_stations,
#'   n = 5
#' )
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
      state_muni = .data$state_muni,
      code_ibge7 = .data$code_ibge7,
      mun_coord  = purrr::map2(.data$lat, .data$lon, c)
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

#' Perform ordinary kriging interpolation of INMET observations
#'
#' Interpolates meteorological observations from INMET weather stations
#' using ordinary kriging and predicts values for a set of target
#' geometries, such as Brazilian municipalities.
#'
#' @param stations_df An `sf` object containing weather station
#'   observations. The object must include point geometries and a
#'   numeric column corresponding to the variable specified in `var`.
#' @param mun_geo An `sf` object containing the target geometries where
#'   predictions will be generated.
#' @param var Character. Name of the numeric variable to interpolate.
#'   Defaults to `"total_rainfall"`.
#' @param range Numeric. Initial value for the range of the spherical
#'   variogram model, in the distance units used by gstat: kilometers for
#'   geographic CRS (e.g. EPSG:4326) and map units (usually meters) for
#'   projected CRS. If `NULL` (default), 500 km is used in either case.
#'
#' @details
#' The empirical variogram is estimated with
#' [gstat::variogram()] and a spherical variogram model is fitted
#' using [gstat::fit.variogram()]. Ordinary kriging is then performed
#' with [gstat::krige()].
#'
#' Both geographic (longitude/latitude, e.g. EPSG:4326) and projected
#' coordinate reference systems (CRS) are supported. With a geographic CRS,
#' gstat computes great-circle distances in kilometers; with a projected CRS,
#' distances are in map units (usually meters). If `mun_geo` uses a different
#' CRS from `stations_df`, it is transformed to the CRS of `stations_df`.
#'
#' Polygon geometries in `mun_geo` trigger block kriging, which is much slower.
#' For municipality-level predictions, consider using centroids
#' ([sf::st_centroid()]).
#'
#' @return
#' An `sf` object containing the geometries from `mun_geo` together with
#' the kriging predictions:
#'
#' * `var1.pred` - Predicted values.
#' * `var1.var` - Prediction variance.
#'
#' @seealso
#' [gstat::krige()],
#' [gstat::variogram()],
#' [gstat::fit.variogram()]
#' @examples
#' # Requires spatial data (e.g., municipal boundaries) together with
#' # INMET station observations. The example dataset `floods_rs`
#' # shows the input format required by `stations_df`.
#' # See the vignette "Spatial Interpolation Using Ordinary Kriging"
#' # for the complete workflow.
#'
#' \dontrun{
#' 
#' krig_df <- kriging_inmet(
#'   stations_df = inmet_data,
#'   mun_geo = municipalities_sf,
#'   var = "total_rainfall"
#' )
#'
#' head(krig_df)
#' }
#'
#' @import sf gstat
#' @importFrom stats as.formula
#' @importFrom dplyr pull
#' @export

kriging_inmet <- function(stations_df, mun_geo, var = 'total_rainfall',
                          range = NULL){

  if (sf::st_crs(stations_df) != sf::st_crs(mun_geo)) {
    mun_geo <- sf::st_transform(mun_geo, sf::st_crs(stations_df))
  }

  if (is.null(range)) {
    longlat <- isTRUE(sf::st_is_longlat(stations_df))
    range <- if (longlat) 500 else 500000
  }

  f_ <- paste0(var, " ~ 1") |>
    as.formula()

  vario_emp <- variogram(f_, data = stations_df)

  vario_mod <- fit.variogram(
    vario_emp,
    model = vgm(
      psill  = var(stations_df |> sf::st_drop_geometry() |> pull(var), na.rm = TRUE),
      model  = "Sph",
      range  = range,
      nugget = 0
    )
  )

  krig_result <- krige(
    formula   = f_,
    locations = stations_df,
    newdata   = mun_geo,
    model     = vario_mod
  )

  return(krig_result)
}
