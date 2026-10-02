# Find the nearest INMET stations for each municipality

Computes the great-circle distance between each municipality and all
INMET stations, returning the \`n\` nearest stations for every
municipality.

## Usage

``` r
nearest_stations(municipality, inmet_stations, n = 5)
```

## Arguments

- municipality:

  A data frame containing the municipality coordinates. Must include the
  columns \`code_ibge7\`, \`lat\`, and \`lon\`.

- inmet_stations:

  A data frame containing the INMET station coordinates. Must include
  the columns \`code_wmo\`, \`lat\`, and \`lon\`.

- n:

  Number of nearest stations to return for each municipality.

## Value

A tibble with the columns:

- state_muni:

  Brazilian state abbreviation.

- code_ibge7:

  Seven-digit IBGE municipality code.

- code_wmo:

  WMO identifier of the INMET station.

- distance:

  Distance (in kilometers) between the municipality and the station.

- station_order:

  Rank of the station by distance, where 1 indicates the nearest
  station.

## Examples

``` r

data("municipality")
data("inmet_stations")

mun_rs <- municipality[municipality$state_muni == "RS", ]

mun_stations1 <- nearest_stations(
  municipality = mun_rs,
  inmet_stations = inmet_stations,
  n = 1
)

# Stations from other states may be returned. This is expected:
# municipalities near state borders may be closer to a station in a
# neighboring state.

mun_stations2 <- nearest_stations(
  municipality = mun_rs,
  inmet_stations = inmet_stations,
  n = 5
)
```
