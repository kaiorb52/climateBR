# climateBR 0.3.0

This release expands climateBR beyond INMET: it adds three new data sources (APAC, MIDR and INPE), a new dataset of APAC monitoring stations, and improvements to `kriging_inmet()`. The package documetation were updated to reflect the broader scope.

## New functions

-   `download_disasters()` — downloads the consolidated database of the *Atlas Digital de Desastres no Brasil* (MIDR, with CEPED/UFSC): natural disaster records registered in S2iD between 1991 and 2025, linked to municipalities through the 7-digit IBGE code. The data are served from a Zenodo mirror as an `.rds` file instead of the CSV on the MIDR portal.
-   `download_firespots()` — downloads the annual fire hotspot records (*focos de queimada*) detected by satellite and published by INPE's *Programa Queimadas*, available from 1998 onwards.
-   `download_apac()` — downloads the historical monthly rainfall records of Pernambuco's Water and Climate Agency (APAC), by mesoregion, available from 1961 onwards. The daily rainfall columns (`01` to `31`) and `Acumulado` are returned as numeric (mm), with APAC's decimal comma converted and `"-"` returned as `NA`. This function requires the suggested packages `chromote` and `rvest` and a local installation of Google Chrome or Chromium. It is based on a script from the [Nimbus Platform](https://github.com/ProjetoNimbuss/nimbus-platform) project.

## Datasets

-   `apac_stations` — a new dataset with metadata for the 1,306 monitoring stations listed by APAC in Pernambuco (conventional and automatic rain gauges, and meteorological, hydrological and agrometeorological stations), including type, status, operator, municipality (IBGE code) and coordinates.

## Removed

-   `mun_stations_distance` was removed. It was superseded by `mun_stations` in 0.2.0 and made up most of the package size. For historical analyses, build a year-specific mapping with `nearest_stations()`.

## Improvements

-   `kriging_inmet()` gains a `range` argument that sets the initial range of the spherical variogram. By default it uses 500 km for both geographic and projected CRS. Before, the range was fixed at 500,000 map units, which was wrong for longitude/latitude data.
-   `kriging_inmet()` now supports geographic CRS (e.g. EPSG:4326), and `mun_geo` is transformed automatically to the CRS of `stations_df` when the two differ.

# climateBR 0.2.5

Minor release: the README and vignettes were revised.

-   `rain_stations` — the `frist_year` column was renamed to `first_year`.

# climateBR 0.2.0

This release adds a new function, replaces the existing datasets with cleaner and more concise versions, and fixes several bugs in downloading data and building the INMET dataset.

## New function

-   `nearest_stations()` — computes the distances between municipalities and INMET stations and returns the stations closest to each municipality.

## Datasets

-   `inmet_stations` — a revised version of `rain_stations`. The older dataset listed INMET stations by year from 2000 to 2024, so the same station appeared many times. The new version uses the most recent station information (through 2026) and has one row per station.
-   `mun_stations` — `mun_stations_distance` contains municipality-to-station distances for every other year from 2008 to 2024. The new `mun_stations` contains the distances computed with `nearest_stations()` and the `inmet_stations` dataset.
-   `municipality` — a new dataset with basic information on Brazilian municipalities: IBGE and TSE codes, state, and centroid latitude and longitude.
-   `floods_rs` — the `id_who` column was renamed to `code_wmo`.

## Bugfixes and Quality of Life

-   Fixed: blank CSV files from 2026 caused `build_inmet_dataset()` to fail.
-   Fixed: the `data` variable had a different type in recent years, which produced an inconsistent partitioned dataset in `build_inmet_dataset()` and caused errors in `read_inmet()`.
-   Added the `years` and `partitioning_by` parameters to `build_inmet_dataset()`.
-   Added a progress bar to the `download_inmet()` and `build_inmet_dataset()` functions.

# climateBR 0.1.0

-   Initial CRAN submission.

-   Functions:

    -   `download_inmet()` — downloads historical weather station data from INMET.
    -   `build_inmet_dataset()` — converts raw CSV files into partitioned Arrow/Parquet datasets.
    -   `read_inmet()` — queries large INMET datasets efficiently.
    -   `kriging_inmet()` — performs ordinary kriging interpolation.
