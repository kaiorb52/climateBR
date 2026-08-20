# Rainfall during the 2024 Rio Grande do Sul floods

Dataset containing accumulated rainfall observed at meteorological
stations operated by the Brazilian National Institute of Meteorology
(INMET) during the extreme flooding event that affected Rio Grande do
Sul, Brazil, in 2024.

## Usage

``` r
floods_rs
```

## Format

A data frame with 545 rows and 4 variables:

- code_wmo:

  Character. World Meteorological Organization (WMO) identifier of the
  INMET weather station.

- lat:

  Numeric. Latitude of the station in decimal degrees (WGS84).

- lon:

  Numeric. Longitude of the station in decimal degrees (WGS84).

- total_rainfall:

  Numeric. Total accumulated rainfall (mm) during the study period.

## Source

Brazilian National Institute of Meteorology (INMET).

## Details

The dataset contains 545 monitoring stations distributed across Brazil.
Each row corresponds to a single INMET weather station and includes its
identification code, geographic coordinates, and the total accumulated
rainfall (in millimeters) recorded between April 27 and May 5, 2024.

## Examples

``` r
head(floods_rs)
#> # A tibble: 6 × 4
#>   code_wmo    lat   lon total_rainfall
#>   <chr>     <dbl> <dbl>          <dbl>
#> 1 A005     -13.5  -49.2            3.4
#> 2 A018     -12.0  -48.6            0  
#> 3 A044      -5.64 -48.1            3.8
#> 4 A101      -3.10 -60.0            6.6
#> 5 A110      -8.78 -67.3           41.8
#> 6 A119      -3.29 -60.6           20.6
summary(floods_rs$total_rainfall)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    0.00    0.00    0.20   37.16   27.60  647.20 
```
