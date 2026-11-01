# Download natural disaster records from the Brazilian Atlas of Natural Disasters

Downloads the consolidated database of the \*Atlas Digital de Desastres
no Brasil\*, maintained by the Ministry of Integration and Regional
Development (MIDR) in partnership with CEPED/UFSC. Each row is a
disaster record registered by a municipality in the Integrated Disaster
Information System (S2iD) between 1991 and 2025.

## Usage

``` r
download_disasters(dest_dir = NULL)
```

## Arguments

- dest_dir:

  Character. Directory where the CSV file is saved (e.g.
  \`"./data/raw/"\`). It is created if it does not exist. If \`NULL\`
  (default), the data are read directly from the MIDR server and nothing
  is written to disk.

## Value

A \`data.table\` with one row per disaster record.

## Details

The data are read with \[data.table::fread()\] and the download timeout
is temporarily raised to at least 600 seconds. When \`dest_dir\` is set,
the CSV is saved there with its original name and, if it already exists,
it is read from disk instead of being downloaded again. Otherwise, the
data are read directly from the MIDR server, so an internet connection
is required.

Records are identified by \`Protocolo_S2iD\` and linked to
municipalities through \`Cod_IBGE_Mun\` (7-digit IBGE code), which can
be joined with \[municipality\] (\`code_ibge7\`) and \[mun_stations\] to
match disasters with INMET weather stations. Events are classified by
the Brazilian Disaster Classification and Codification (COBRADE;
\`Cod_Cobrade\`, \`descricao_tipologia\`, \`grupo_de_desastre\`).

Column-name prefixes group the reported impacts:

- \`DH\_\`:

  Human damages (deaths, injured, homeless, displaced, etc.).

- \`DM\_\`:

  Material damages (damaged/destroyed housing, health, education and
  infrastructure units, and their values in BRL).

- \`DA\_\`:

  Environmental damages.

- \`PEPL\_\`:

  Public economic losses, in BRL.

- \`PEPR\_\`:

  Private economic losses, in BRL.

Column names and date formats (\`dd/mm/yyyy\`) are kept as distributed
by the source. More information: \<https://atlasdigital.mdr.gov.br\>.

## See also

\[municipality\], \[mun_stations\], \[read_inmet()\]

## Examples

``` r
if (FALSE) { # \dontrun{

disasters <- download_disasters()

## Keep the CSV file locally
disasters <- download_disasters(dest_dir = "./data/raw/")

} # }
```
