\name{kriging_inmet}
\alias{kriging_inmet}
\title{Perform Ordinary Kriging for INMET Meteorological Data}
\usage{
kriging_inmet(
  inmet_df,
  stations_geo,
  mun_geo,
  var = "total_rainfall"
)
}
\arguments{
  \item{inmet_df}{
    A \code{data.frame} containing observations from weather stations.
    Must include a numeric column corresponding to the variable specified
    in \code{var}.
  }

  \item{stations_geo}{
    An \code{sf} object containing the geographic locations of weather
    stations. Must include the variable specified in \code{var}.
  }

  \item{mun_geo}{
    An \code{sf} object containing the geometries of municipalities or
    other target locations where kriging predictions will be generated.
  }

  \item{var}{
    A character string indicating the name of the variable to be
    interpolated. Defaults to \code{"total_rainfall"}.
  }
}
\value{
An \code{sf} object containing the geometries from \code{mun_geo}
together with the kriging output variables:

\describe{
  \item{var1.pred}{Predicted value of the interpolated variable.}
  \item{var1.var}{Prediction variance associated with the estimate.}
}
}
\description{
Applies ordinary kriging interpolation to meteorological observations
collected from INMET weather stations, producing spatial estimates of a
selected variable for Brazilian municipalities or other target spatial
units.
}
\examples{
\dontrun{
krig_result <- kriging_inmet(
  inmet_df = inmet_data,
  stations_geo = stations_sf,
  mun_geo = municipalities_sf,
  var = "total_rainfall"
)

head(krig_result)
}
}
\seealso{
\code{\link[gstat]{krige}},
\code{\link[gstat]{variogram}},
\code{\link[gstat]{fit.variogram}}
}