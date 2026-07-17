
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
