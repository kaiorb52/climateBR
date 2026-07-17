# climateBR 0.1.0

* Initial CRAN submission.

- Functions:
  `download_inmet()` - download historical weather station data from INMET.
  `build_inmet_dataset()` - convert raw CSV files into partitioned Arrow/Parquet datasets.
  `read_inmet()` - efficient querying of large INMET datasets.
  `kriging_inmet()` - ordinary kriging interpolation.
