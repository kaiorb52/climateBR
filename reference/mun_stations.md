# Nearest INMET Weather Stations for Brazilian Municipalities

A dataset containing the five nearest INMET weather stations for each
Brazilian municipality based on the distance between the municipality
centroid and the station location.

## Usage

``` r
mun_stations
```

## Format

A tibble with 27,850 rows and 5 variables:

- state_muni:

  Brazilian state abbreviation.

- code_ibge7:

  Seven-digit IBGE municipality code.

- code_wmo:

  World Meteorological Organization (WMO) identifier of the INMET
  weather station.

- distance:

  Distance between the municipality centroid and the station, in
  kilometers.

- station_order:

  Rank of the station by proximity, where 1 indicates the nearest
  station.

## Source

Distances were computed from municipality centroid coordinates and INMET
station coordinates using the Haversine formula.

## Details

Distances were calculated using the Haversine formula. Each municipality
is associated with its five closest INMET stations, ordered by
increasing distance.

The dataset was generated with \[nearest_stations()\], matching each
municipality centroid to the five closest stations in the
\`inmet_stations\` dataset.

It reflects the most recent INMET station network and is intended for
analyses of recent observations. Because stations are added and removed
over time, do not use it to match data from earlier years. For
historical analyses, use \`mun_stations_distance\` or build a
year-specific mapping with \[nearest_stations()\] and the station
network of that year.

## Examples

``` r
data(mun_stations)
head(mun_stations)
#> # A tibble: 6 × 5
#>   state_muni code_ibge7 code_wmo distance station_order
#>   <chr>           <dbl> <chr>       <dbl>         <int>
#> 1 RO            1100015 A939        138.              1
#> 2 RO            1100015 A938        217.              2
#> 3 RO            1100015 S104        218.              3
#> 4 RO            1100015 S101        248.              4
#> 5 RO            1100015 A963        285.              5
#> 6 RO            1100023 A940         10.8             1
```
