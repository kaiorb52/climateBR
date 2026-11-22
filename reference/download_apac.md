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

  Character. Directory where the files are saved (e.g.
  \`"./data/raw/"\`). It is created if it does not exist. If \`NULL\`
  (default), a temporary directory is used.

- progress:

  Logical. If \`TRUE\` (default), displays a progress bar while querying
  APAC.

## Value

A data frame with one row per rain gauge and month, combining all
requested \`years\` and \`mesoregions\`, with numeric rainfall columns
(\`01\` to \`31\` and \`Acumulado\`).

## Details

Source: Pernambuco's Water and Climate Agency (APAC). More information:
\<http://old.apac.pe.gov.br/meteorologia/monitoramento-pluvio.php\>.

This function requires a local installation of Google Chrome or
Chromium.

Each row is a rain gauge (\`Código\`, \`Posto\`) and month
(\`Mês/Ano\`), with daily rainfall in mm (\`01\` to \`31\`) and the
monthly total (\`Acumulado\`). Missing values are returned as \`NA\`.

Mesoregion/years whose file already exists in \`dest_dir\` are read from
disk instead of being queried again. If a file is corrupted, delete it
and run the function again. Queries that fail raise a warning and are
skipped.

This function is based on a script from the Nimbus Platform project
(\<https://github.com/ProjetoNimbuss/nimbus-platform\>).

## See also

\[download_inmet()\], \[download_firespots()\], \[download_disasters()\]

## Examples

``` r
if (FALSE) { # \dontrun{

## Download a single year for the Metropolitan Region of Recife
apac <- download_apac(years = 2020, mesoregions = 2605)

## Download multiple years for all mesoregions, keeping the files
apac <- download_apac(years = 2020:2024, dest_dir = "./data/raw/")

} # }
```
