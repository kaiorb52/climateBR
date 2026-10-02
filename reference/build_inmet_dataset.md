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
  region = "all",
  state = "all",
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

  Integer vector. Years of INMET data in \`input\` to convert into the
  Arrow/Parquet dataset. Defaults to \`2000:2026\`.

- partitioning_by:

  Character vector. Variable(s) used to partition the dataset; each
  variable creates one level of Parquet folders. Defaults to \`c("ano",
  "codigo_wmo")\`.

- region:

  Character vector. INMET region abbreviation(s) to filter (e.g.
  \`"NE"\`, \`"SE"\`). Defaults to \`"all"\`, which applies no filter.

- state:

  Character vector. Brazilian state abbreviation(s) (\`uf\`) to filter
  (e.g. \`"BA"\`, \`"SP"\`). Defaults to \`"all"\`, which applies no
  filter.

- progress:

  Logical. If \`TRUE\` (default), displays a progress bar while
  processing the INMET files.

## Value

Invisibly returns the output directory.

## Details

During the conversion, metadata are extracted from each file, column
names are standardized, numeric variables are converted to numeric
format, and the resulting dataset is partitioned (by default) by year
(\`ano\`) and WMO station code (\`codigo_wmo\`).

This function only needs to be executed once for a collection of
downloaded INMET files. After the dataset has been created, it can be
accessed efficiently using \[read_inmet()\] without repeatedly parsing
the original CSV files.

With the default partitioning by year (\`ano\`) and weather station
(\`codigo_wmo\`), Arrow reads only the files required by a query.

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
#> Error: No files found for region = all and state = all. Check if this is a valid combination.

# }
```
