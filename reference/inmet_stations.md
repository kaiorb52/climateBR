# INMET rainfall monitoring stations

Dataset containing metadata for rainfall monitoring stations operated by
the Brazilian National Institute of Meteorology (INMET). Each row
represents a specific meteorological station collect based on data from
2000 to 2026.

## Usage

``` r
inmet_stations
```

## Format

A data frame with 700 rows and 6 variables:

- state_station:

  Brazilian state abbreviation.

- code_wmo:

  WMO station identifier.

- lat:

  Station Latitude in decimal degrees (WGS84).

- lon:

  Station Longitude in decimal degrees (WGS84).

- creation_year:

  First year with available observations for the station.

- last_used_year:

  Last year with available observations for the station.

## Source

Instituto Nacional de Meteorologia (INMET).

## Details

The dataset includes station identifiers, location information, state,
municipality codes, and the first and last years in which data are
available for each station.

## Examples

``` r
data(inmet_stations)
head(inmet_stations)
#> # A tibble: 6 × 6
#> # Groups:   code_wmo [6]
#>   state_station code_wmo    lat   lon creation_year last_used_year
#>   <chr>         <chr>     <dbl> <dbl>         <int>          <int>
#> 1 DF            A001     -15.8  -47.9          2000             NA
#> 2 AM            A101      -3.10 -60.0          2000             NA
#> 3 BA            A401     -13.0  -38.5          2000             NA
#> 4 RS            A801     -30.0  -51.2          2000             NA
#> 5 RJ            A601     -22.8  -43.7          2000             NA
#> 6 GO            A002     -16.6  -49.2          2001             NA
```
