# climateBR 0.2.0

This new release introduces a new function, revamps the existing datasets with cleaner and more concise versions, and, most importantly, fixes several bugs related to downloading data and building the INMET database.

## New function

-   `nearest_stations` — helps users identify the distances between municipalities and INMET stations and determine which stations are closest to each municipality.

## Datasets

-   `inmet_stations` — this dataset is essentially a revamped version of the previous `rain_stations` dataset. The older dataset contained information on INMET stations available from 2000 to 2024, meaning that the same station could appear multiple times across different years. The new version uses the most recent station information available through 2026 and contains one observation per station, avoiding unnecessary repetition.
-   `mun_stations` — the previous `mun_stations_distance` dataset contained the distances between municipalities and INMET stations for every two-year period from 2008 to 2024. This new version contains the distances calculated between municipalities and INMET stations using the `inmet_stations` dataset and the `nearest_stations` function.
-   `municipality` — a brand-new dataset containing basic information on Brazilian municipalities, including IBGE and TSE municipality codes, state, and the latitude and longitude of each municipality's centroid.
-   `floods_rs` —  renamed the 'id_who' column to 'code_wmo'.

## Bugfixes and Quality of Life

-   Blank CSV files from 2026 could cause the `build_inmet_dataset` process to fail. This bug has been fixed.
-   The `data` variable in the time series from later years were categorized differently, which could result in an inconsistent partitioned database when using `build_inmet_dataset` and cause errors when running `read_inmet`.
-   New parameters `years` and `partitioning_by`, have been added to `build_inmet_dataset`.
-   Added a progress bar to the `download_inmet()` and `build_inmet_dataset()` functions.

# climateBR 0.1.0

-   Initial CRAN submission.

-   Functions:

    -   `download_inmet()` — download historical weather station data from INMET.
    -   `build_inmet_dataset()` — convert raw CSV files into partitioned Arrow/Parquet datasets.
    -   `read_inmet()` — efficient querying of large INMET datasets.
    -   `kriging_inmet()` — ordinary kriging interpolation.
