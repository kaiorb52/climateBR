# APAC rainfall and weather monitoring stations (Pernambuco)

Dataset containing metadata for the monitoring stations listed by
Pernambuco's Water and Climate Agency (APAC). It includes rain gauges
and meteorological, hydrological, and agrometeorological stations
operated by APAC and partner institutions (Cemaden, ANA, INMET, INPE,
and IPA). Each row is one station.

## Usage

``` r
apac_stations
```

## Format

A tibble with 1,306 rows and 14 variables:

- code_gmmc:

  Station code used by APAC. It usually starts with the IBGE
  municipality code and ends with a letter for the station type, but
  this pattern is not guaranteed. A few codes are shared by different
  stations.

- station_name:

  Station name as registered by APAC.

- station_type:

  Type of station: \`"Conventional rain gauge"\`, \`"Automatic rain
  gauge"\`, \`"Meteorological station"\`, \`"Hydrological station"\`,
  \`"Agrometeorological station"\`, or \`"Acqua station"\`.

- status:

  Station status at the time of collection: \`"active"\`,
  \`"inactive"\`, or \`"maintenance"\`.

- operator:

  Institution that operates the station.

- owner:

  Institution that owns the station.

- state_station:

  Brazilian state abbreviation (always \`"PE"\`).

- code_ibge7:

  Seven-digit IBGE code of the municipality where the station is
  located.

- name_muni:

  Name of the municipality where the station is located.

- location:

  Installation site (e.g. a school, a district, or a public building).

- manufacturer:

  Equipment manufacturer.

- model:

  Equipment model.

- lat:

  Station latitude in decimal degrees (WGS84).

- lon:

  Station longitude in decimal degrees (WGS84).

## Source

Agência Pernambucana de Águas e Clima (APAC),
\<https://www.apac.pe.gov.br\>.

## Details

The station list was collected from the APAC API on 2026-11-01 and
reflects the network status on that date. Municipality codes were
matched by municipality name. Coordinates that fall outside Pernambuco
(registration errors in the source) were set to \`NA\`.

Rainfall series published by APAC can be downloaded with
\[download_apac()\].

## Examples

``` r
data(apac_stations)
head(apac_stations)
#> # A tibble: 6 × 15
#>   code_apac  code_gmmc  station_name          station_type status operator owner
#>   <chr>      <chr>      <chr>                 <chr>        <chr>  <chr>    <chr>
#> 1 260005401A 260005401A [CEMADEN] Distrito I… Automatic r… inact… Cemaden  Cema…
#> 2 198        260005401V Abreu e Lima [Conven… Conventiona… active APAC     APAC 
#> 3 260005402A 260005402A [APAC] Trindade Santa Automatic r… active APAC     APAC 
#> 4 Tplu002    Tplu002    Estação Tplu002       NA           inact… NA       NA   
#> 5 260010401A 260010401A [APAC] ETA Compesa    Automatic r… active APAC     APAC 
#> 6 501        260010401H Afogados da Ingazeir… Hydrologica… inact… APAC     APAC 
#> # ℹ 8 more variables: state_station <chr>, code_ibge7 <dbl>, name_muni <chr>,
#> #   location <chr>, manufacturer <chr>, model <chr>, lat <dbl>, lon <dbl>
table(apac_stations$station_type, apac_stations$status)
#>                             
#>                              active inactive maintenance
#>   Acqua station                  10        0           0
#>   Agrometeorological station      3        5           6
#>   Automatic rain gauge          316       67          50
#>   Conventional rain gauge       217      309           0
#>   Hydrological station            5       87           3
#>   Meteorological station         43       35          16
```
