# Build a partitioned Arrow dataset from INMET CSV files

Converts the raw CSV files downloaded from INMET into a partitioned
Arrow/Parquet dataset optimized for fast querying with \[read_inmet()\].

## Usage

``` r
build_inmet_dataset(
  input,
  output,
  years = 2000:2026,
  partitioning_by = c("ano", "codigo_wmo"),
  progress = TRUE
)
```

## Arguments

- input:

  Character. Directory containing the raw CSV files downloaded with
  \[download_inmet()\].

- output:

  Character. Directory where the partitioned Arrow/Parquet dataset will
  be written.

- years:

  Vector. Group of years of the INMET database located in \`input\` to
  be transformed into an Arrow/Parquet dataset.

- partitioning_by:

  Vector. Variable(s) in the INMET database used to create the parquet
  folders.

- progress:

  Logical. Should a progress bar be displayed while the INMET files are
  being processed? Defaults to \`TRUE\`. Set to \`FALSE\` to disable the
  progress bar.

## Value

Invisibly returns the output directory.

## Details

During the conversion, metadata are extracted from each file, column
names are standardized, numeric variables are converted to numeric
format, and the resulting dataset is partitioned by year (\`ano\`) and
WMO station code (\`codigo_wmo\`).

This function only needs to be executed once for a collection of
downloaded INMET files. After the dataset has been created, it can be
accessed efficiently using \[read_inmet()\] without repeatedly parsing
the original CSV files.

The resulting dataset is partitioned by year (\`ano\`) and weather
station (\`codigo_wmo\`), allowing Arrow to read only the files required
by a query.

## See also

\[download_inmet()\], \[read_inmet()\]

## Examples

``` r
# \donttest{

build_inmet_dataset(
  input = file.path(tempdir(), "inmet_raw"),
  output = file.path(tempdir(), "inmet_arrow"),
  progress = FALSE
)

# }
```
