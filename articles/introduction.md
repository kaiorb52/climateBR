# climateBR: An R package to download meteorological data from Brazil

## Introduction

The main goal of the package is to facilitate research on climate shocks
by providing functions that support the different stages of working with
climate data. The `download_inmet` function downloads ZIP files
containing data from INMET weather stations from the Brazilian
government’s website. `build_inmet_dataset` helps users create a
partitioned database from INMET data, while `read_inmet` provides access
to this database. Functions such as `nearest_station` and
`kriging_inmet` connect municipalities to the INMET database, allowing
researchers to match climate data with information from other sources,
such as IBGE or TSE. This makes it possible to conduct correlations and
other forms of statistical analysis.

This vignette demonstrates the central functions for working with
**climateBR**. I hope that you enjoy the ride.

### Installation

#### Stable Build

``` r

install.packages("climateBR")
```

#### Dev. Build

``` r

# install.packages("remotes")

remotes::install_github("kaiorb52/climateBR")
```

### Download data

The first step is downloading the original files published by INMET.

``` r


raw_dir <- file.path(tempdir(), "inmet_raw")
dataset_dir <- file.path(tempdir(), "inmet_arrow")

download_inmet(
  years = 2000:2005,
  unzip_to = raw_dir
)
```

### Build the dataset

Once the files have been downloaded, they can be converted into a
partitioned Arrow dataset. This only needs to be done once and allows
much faster access for subsequent analyses.

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

Keeping `collect = FALSE` is generally recommended when working with
large time spans, as the full INMET database contains millions of
observations. Loading all records into memory with `collect = TRUE` may
exceed the available RAM and cause R to explode.

``` r

rainfall <- read_inmet(
  path = dataset_dir,
  years = 2000,
  collect = FALSE
)
```

Depending on the selected years, it is also good practice to inspect and
clean the observations before analysis. In some historical INMET files,
missing values are encoded as `-9999` instead of `NA`, so these values
should be converted to proper missing values before computing summaries
or running models.

### How to Cite

When using `climateBR` in academic publications, please cite the package
as follows:

``` r

citation("climateBR")
#> To cite package 'climateBR' in publications use:
#> 
#>   Bárbara K (2026). _climateBR: Download Rainfall, Temperature, and
#>   Wind Data from Brazil_. R package version 0.2.0,
#>   <https://github.com/kaiorb52/climateBR>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {climateBR: Download Rainfall, Temperature, and Wind Data from Brazil},
#>     author = {Kaio Bárbara},
#>     year = {2026},
#>     note = {R package version 0.2.0},
#>     url = {https://github.com/kaiorb52/climateBR},
#>   }
```
