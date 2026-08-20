# Download historical meteorological data from INMET

Downloads historical weather station data from the Brazilian National
Institute of Meteorology (INMET) and extracts the downloaded ZIP files
into a user-specified directory.

## Usage

``` r
download_inmet(years = 2008, unzip_to = tempdir(), progress = TRUE)
```

## Arguments

- years:

  Integer vector specifying the years to download. Historical data are
  available from 2000 onwards. The default is \`2008\`.

- unzip_to:

  Character. Directory where the downloaded files will be extracted.

- progress:

  Logical. Should a progress bar be displayed while the INMET files are
  being processed? Defaults to \`TRUE\`. Set to \`FALSE\` to disable the
  progress bar.

## Value

This function is called for its side effects. ZIP files are downloaded,
extracted into \`unzip_to\`, and the extracted files are stored on disk.

## Details

INMET provides historical observations dating back to 2000. However,
only a small number of weather stations were operating in the early
years of the dataset. For most applications, we recommend using data
from \*\*2008 onwards\*\*, when the monitoring network became
substantially more comprehensive.

Existing directories containing extracted files are skipped to avoid
downloading the same data multiple times.

The downloaded files can subsequently be processed with
\[build_inmet_dataset()\].

## See also

\[build_inmet_dataset()\], \[read_inmet()\]

## Examples

``` r
# \donttest{

## Download a single year
download_inmet(
  years = 2000,
  unzip_to = tempdir()
)
#>   |                                                                              |                                                                      |   0%  |                                                                              |======================================================================| 100%

## Download multiple years
download_inmet(
  years = 2004:2006,
  unzip_to = tempdir()
)
#>   |                                                                              |                                                                      |   0%  |                                                                              |=======================                                               |  33%  |                                                                              |===============================================                       |  67%  |                                                                              |======================================================================| 100%

# }
```
