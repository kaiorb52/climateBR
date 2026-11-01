# Download historical rainfall data from APAC (Pernambuco)

Downloads the historical monthly rainfall records published by
Pernambuco's Water and Climate Agency (APAC) on its rainfall monitoring
portal, for one or more of the state's mesoregions.

## Usage

``` r
download_apac(
  years = 2025,
  mesoregions = 2601:2605,
  dest_dir = NULL,
  progress = TRUE
)
```

## Arguments

- years:

  Integer vector specifying the years to download. Historical data are
  available from 1961 onwards. The default is \`2025\`.

- mesoregions:

  Integer vector of IBGE mesoregion codes to download. The default is
  all five mesoregions of Pernambuco: \`2601\` (Sertão Pernambucano),
  \`2602\` (São Francisco Pernambucano), \`2603\` (Agreste
  Pernambucano), \`2604\` (Mata Pernambucana) and \`2605\`
  (Metropolitana do Recife).

- dest_dir:

  Character. Directory where the CSV files are saved (e.g.
  \`"./data/raw/"\`). It is created if it does not exist. If \`NULL\`
  (default), files are saved to a temporary directory and discarded at
  the end of the R session.

- progress:

  Logical. If \`TRUE\` (default), displays a progress bar while querying
  APAC.

## Value

A data frame with one row per rain gauge and month, combining all
requested \`years\` and \`mesoregions\`, with numeric rainfall columns
(\`01\` to \`31\` and \`Acumulado\`).

## Details

APAC's portal
(\<http://old.apac.pe.gov.br/meteorologia/monitoramento-pluvio.php\>)
renders its results table dynamically with JavaScript, so there is no
static file to download. Instead, a headless Chrome session is driven
through the chromote package to query each mesoregion/year, and the
results table is parsed with rvest. This requires a local installation
of Google Chrome or Chromium, and the chromote and rvest packages.

Each mesoregion/year is saved to \`dest_dir\` as
\`apac_mesoregion_year.csv\`. Files that already exist in \`dest_dir\`
are read from disk instead of being queried again. Queries that fail
raise a warning and are skipped.

Column names are kept as distributed by the source (e.g. \`Código\`,
\`Posto\`, \`Mês/Ano\`), plus \`cod_mesorregiao\` and \`ano\`. The daily
rainfall columns (\`01\` to \`31\`) and \`Acumulado\` are returned as
numeric (mm): APAC's decimal comma is converted to a decimal point and
missing values, shown as \`"-"\` on the portal, are returned as \`NA\`.
The CSV files saved to \`dest_dir\` keep the raw values as distributed
by APAC.

This function is based on a script from the Nimbus Platform project
(\<https://github.com/ProjetoNimbuss/nimbus-platform\>).

## See also

\[download_inmet()\], \[download_firespots()\], \[download_disasters()\]

## Examples

``` r
if (FALSE) { # \dontrun{

## Download a single year for the Metropolitan Region of Recife
apac <- download_apac(years = 2020, mesoregions = 2605)

## Download multiple years for all mesoregions, keeping the CSV files
apac <- download_apac(years = 2020:2024, dest_dir = "./data/raw/")

} # }
```
