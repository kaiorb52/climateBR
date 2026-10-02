# climateBR: An R package to download meteorological data from Brazil

## Introduction

**climateBR** supports research on climate shocks by providing functions
for each stage of working with climate data:

- [`download_inmet()`](../reference/download_inmet.md) downloads the ZIP
  files with INMET weather station data from the Brazilian government’s
  website.
- [`build_inmet_dataset()`](../reference/build_inmet_dataset.md)
  converts the raw files into a partitioned dataset.
- [`read_inmet()`](../reference/read_inmet.md) reads and filters that
  dataset.
- [`nearest_stations()`](../reference/nearest_stations.md) and
  [`kriging_inmet()`](../reference/kriging_inmet.md) link municipalities
  to INMET stations, so climate data can be merged with other sources,
  such as IBGE or TSE, for statistical analysis.

This vignette demonstrates the core workflow of **climateBR**.

### Installation

#### Stable version (CRAN)

``` r

install.packages("climateBR")
```

#### Development version

``` r

# install.packages("remotes")

remotes::install_github("kaiorb52/climateBR")
```

### Download data

First, download the original files published by INMET.

``` r


raw_dir <- file.path(tempdir(), "inmet_raw")
dataset_dir <- file.path(tempdir(), "inmet_arrow")

download_inmet(
  years = 2000:2005,
  unzip_to = raw_dir
)
```

### Build the dataset

Next, convert the downloaded files into a partitioned Arrow dataset.
This only needs to be done once and makes later analyses much faster.

``` r

build_inmet_dataset(
  input = raw_dir,
  output = dataset_dir
)
```

### Read the dataset

The [`read_inmet()`](../reference/read_inmet.md) function reads the
partitioned dataset and can return either an Arrow Dataset
(`collect = FALSE`) or an in-memory data frame (`collect = TRUE`).

Keep `collect = FALSE` when working with long time spans: the full INMET
dataset contains millions of observations, and loading all of them into
memory with `collect = TRUE` may exceed the available RAM and crash R.

``` r

rainfall <- read_inmet(
  path = dataset_dir,
  years = 2000,
  collect = FALSE
)
```

Inspect and clean the observations before analysis. In some historical
INMET files, missing values are coded as `-9999` instead of `NA`;
convert them to `NA` before computing summaries or fitting models.

### How to Cite

When using `climateBR` in academic publications, please cite the package
as follows:

``` r

citation("climateBR")
#> To cite package 'climateBR' in publications use:
#> 
#>   Bárbara K (2026). _climateBR: Download Rainfall, Temperature, and
#>   Wind Data from Brazil_. R package version 0.2.5,
#>   <https://github.com/kaiorb52/climateBR>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {climateBR: Download Rainfall, Temperature, and Wind Data from Brazil},
#>     author = {Kaio Bárbara},
#>     year = {2026},
#>     note = {R package version 0.2.5},
#>     url = {https://github.com/kaiorb52/climateBR},
#>   }
```
