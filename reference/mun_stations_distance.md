# Distance Between Brazilian Municipal Centroids and INMET Rainfall Stations

A dataset containing the distances between the centroids of Brazilian
municipalities and rainfall stations operated by the Brazilian National
Institute of Meteorology (INMET). Distances were computed using the
Haversine formula.

## Usage

``` r
mun_stations_distance
```

## Format

A data frame with the following variables:

- code_muni:

  Seven-digit IBGE municipality code.

- codigo_wmo:

  WMO identifier of the INMET rainfall station.

- distance:

  Distance between the municipality centroid and the station, in
  kilometers.

- i:

  Rank of the station by distance, where 1 indicates the nearest
  station.

- ano:

  Reference year (2008, 2010, ..., 2024).

## Source

Distances computed from municipality centroids and INMET rainfall
station coordinates using the Haversine formula.

## Details

The dataset covers the period from 2008 to 2024. Because the INMET
station network changes over time, distances were calculated for
snapshots taken every two years (2008, 2010, 2012, 2014, 2016, 2018,
2020, 2022, 2024).

Each municipality is associated with all available INMET stations for
the corresponding year, ordered by increasing distance. The variable
\`i\` indicates the rank of the station according to its proximity to
the municipality centroid.

## Examples

``` r
data(mun_stations_distance)
head(mun_stations_distance)
#>   code_muni codigo_wmo distance i  ano
#> 1   1100015       A939 137.8050 1 2008
#> 2   1100015       A938 216.6878 2 2008
#> 3   1100015       A940 295.1434 3 2008
#> 4   1100015       A925 437.9837 4 2008
#> 5   1100015       A112 517.7160 5 2008
#> 6   1100015       A111 631.3020 6 2008
```
