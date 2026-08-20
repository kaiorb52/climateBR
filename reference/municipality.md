# Municipality Database

Municipality Database

## Usage

``` r
municipality
```

## Format

A data frame with the following variables:

- state_muni:

  Brazilian state abbreviation.

- code_ibge7:

  Seven-digit IBGE municipality code.

- code_ibge6:

  Six-digit IBGE municipality code.

- code_tse:

  Six-digit IBGE municipality code.

- lat:

  Municipality Centroid Latitude in decimal degrees (WGS84).

- lon:

  Municipality Centroid Longitude in decimal degrees (WGS84).

## Examples

``` r
data(municipality)
head(municipality)
#>   state_muni code_ibge7 code_ibge6 code_tse       lon        lat
#> 1         RO    1100023     110002       78 -63.05620  -9.978113
#> 2         RO    1100106     110010       19 -64.41661 -11.321703
#> 3         RO    1100114     110011      159 -62.55423 -10.650432
#> 4         RO    1100130     110013      396 -61.92695  -9.190074
#> 5         RO    1100205     110020       35 -63.99497  -8.988166
#> 6         RO    1100262     110026      647 -62.83627  -9.687693
```
