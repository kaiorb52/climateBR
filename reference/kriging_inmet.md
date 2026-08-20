# Perform ordinary kriging interpolation of INMET observations

Interpolates meteorological observations from INMET weather stations
using ordinary kriging and predicts values for a set of target
geometries, such as Brazilian municipalities.

## Usage

``` r
kriging_inmet(stations_df, mun_geo, var = "total_rainfall")
```

## Arguments

- stations_df:

  An \`sf\` object containing weather station observations. The object
  must include point geometries and a numeric column corresponding to
  the variable specified in \`var\`.

- mun_geo:

  An \`sf\` object containing the target geometries where predictions
  will be generated.

- var:

  Character. Name of the numeric variable to interpolate. Defaults to
  \`"total_rainfall"\`.

## Value

An \`sf\` object containing the geometries from \`mun_geo\` together
with the kriging predictions:

\* \`var1.pred\` - Predicted values. \* \`var1.var\` - Prediction
variance.

## Details

The empirical variogram is estimated with \[gstat::variogram()\] and a
spherical variogram model is fitted using \[gstat::fit.variogram()\].
Ordinary kriging is then performed with \[gstat::krige()\].

Both \`stations_df\` and \`mun_geo\` must use the same projected
coordinate reference system (CRS). Using geographic coordinates
(longitude/latitude) is not recommended for kriging because distance
calculations are performed in map units.

## See also

\[gstat::krige()\], \[gstat::variogram()\], \[gstat::fit.variogram()\]

## Examples

``` r
# Requires spatial data (e.g., municipal boundaries) together with
# INMET stations observations. The example dataset `floods_rs`
# illustrates the required input format for the `stations_df` parameter. 
# See the vignette "Spatial Interpolation Using Ordinary Kriging" 
# for the complete workflow of this function.

if (FALSE) { # \dontrun{

krig_df <- kriging_inmet(
  stations_df = inmet_data,
  mun_geo = municipalities_sf,
  var = "total_rainfall"
)

head(krig_df)
} # }
```
