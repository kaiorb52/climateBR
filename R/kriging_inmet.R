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
#'
#' @details
#' The empirical variogram is estimated with
#' [gstat::variogram()] and a spherical variogram model is fitted
#' using [gstat::fit.variogram()]. Ordinary kriging is then performed
#' with [gstat::krige()].
#'
#' Both `stations_df` and `mun_geo` must use the same projected
#' coordinate reference system (CRS). Using geographic coordinates
#' (longitude/latitude) is not recommended for kriging because distance
#' calculations are performed in map units.
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
#'
#' @examples
#' \dontrun{
#' krig_result <- kriging_inmet(
#'   stations_df = inmet_data,
#'   mun_geo = municipalities_sf,
#'   var = "total_rainfall"
#' )
#'
#' head(krig_result)
#' }
#'
#' @import sf gstat
#' @importFrom stats as.formula
#' @importFrom dplyr pull
#' @export

kriging_inmet <- function(stations_df, mun_geo, var = 'total_rainfall'){

  f_ <- paste0(var, " ~ 1") |>
    as.formula()

  vario_emp <- variogram(f_, data = stations_df)

  vario_mod <- fit.variogram(
    vario_emp,
    model = vgm(
      psill  = var(stations_df |> sf::st_drop_geometry() |> pull(var), na.rm = TRUE),
      model  = "Sph",
      range  = 500000,
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
