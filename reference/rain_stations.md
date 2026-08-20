# INMET rainfall monitoring stations by year

Dataset containing metadata for rainfall monitoring stations operated by
the Brazilian National Institute of Meteorology (INMET). Each row
represents a meteorological station in a specific year between 2000 and
2024.

## Usage

``` r
rain_stations
```

## Format

A data frame with 9,459 rows and 11 variables:

- uf:

  Brazilian state abbreviation.

- estacao:

  Name of the meteorological station.

- codigo_wmo:

  WMO station identifier.

- ano:

  Reference year.

- nome_formatado:

  Standardized station name.

- frist_year:

  First year with available observations for the station.

- last_year:

  Last year with available observations for the station.

- id_ibge7:

  Seven-digit IBGE municipality code.

- id_tse:

  Municipality code used by the Brazilian Electoral Court (TSE).

- latitude:

  Latitude in decimal degrees (WGS84).

- longitude:

  Longitude in decimal degrees (WGS84).

## Source

Instituto Nacional de Meteorologia (INMET).

## Details

The dataset includes station identifiers, location information, state,
municipality codes, and the first and last years in which data are
available for each station.

## Examples

``` r
head(rain_stations)
#> # A tibble: 6 × 11
#>   uf    estacao   codigo_wmo ano   nome_formatado frist_year last_year id_ibge7
#>   <chr> <chr>     <chr>      <chr> <chr>          <chr>      <chr>        <dbl>
#> 1 RO    ARIQUEMES A940       2024  ariquemes      2008       2024       1100023
#> 2 RO    ARIQUEMES A940       2023  ariquemes      2008       2024       1100023
#> 3 RO    ARIQUEMES A940       2022  ariquemes      2008       2024       1100023
#> 4 RO    ARIQUEMES A940       2021  ariquemes      2008       2024       1100023
#> 5 RO    ARIQUEMES A940       2020  ariquemes      2008       2024       1100023
#> 6 RO    ARIQUEMES A940       2019  ariquemes      2008       2024       1100023
#> # ℹ 3 more variables: id_tse <dbl>, latitude <dbl>, longitude <dbl>
unique(rain_stations$ano)
#>  [1] "2024" "2023" "2022" "2021" "2020" "2019" "2018" "2017" "2016" "2015"
#> [11] "2014" "2013" "2012" "2011" "2010" "2009" "2008" "2007" "2006" "2005"
#> [21] "2004" "2003" "2002" "2001" "2000"
```
