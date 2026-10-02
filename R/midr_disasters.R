#' Download natural disaster records from the Brazilian Atlas of Natural Disasters
#'
#' Downloads the consolidated database of the *Atlas Digital de Desastres no
#' Brasil*, maintained by the Ministry of Integration and Regional Development
#' (MIDR) in partnership with CEPED/UFSC. Each row is a disaster record
#' registered by a municipality in the Integrated Disaster Information System
#' (S2iD) between 1991 and 2025.
#'
#' @param dest_dir Character. Directory where the CSV file is saved
#'   (e.g. `"./data/raw/"`). It is created if it does not exist. If `NULL`
#'   (default), the data are read directly from the MIDR server and nothing
#'   is written to disk.
#'
#' @details
#' The data are read with [data.table::fread()] and the download timeout is
#' temporarily raised to at least 600 seconds. When `dest_dir` is set, the
#' CSV is saved there with its original name and, if it already exists, it
#' is read from disk instead of being downloaded again. Otherwise, the data
#' are read directly from the MIDR server, so an internet connection is
#' required.
#'
#' Records are identified by `Protocolo_S2iD` and linked to municipalities
#' through `Cod_IBGE_Mun` (7-digit IBGE code), which can be joined with
#' [municipality] (`code_ibge7`) and [mun_stations] to match disasters with
#' INMET weather stations. Events are classified by the Brazilian Disaster
#' Classification and Codification (COBRADE; `Cod_Cobrade`,
#' `descricao_tipologia`, `grupo_de_desastre`).
#'
#' Column-name prefixes group the reported impacts:
#' \describe{
#'   \item{`DH_`}{Human damages (deaths, injured, homeless, displaced, etc.).}
#'   \item{`DM_`}{Material damages (damaged/destroyed housing, health,
#'     education and infrastructure units, and their values in BRL).}
#'   \item{`DA_`}{Environmental damages.}
#'   \item{`PEPL_`}{Public economic losses, in BRL.}
#'   \item{`PEPR_`}{Private economic losses, in BRL.}
#' }
#'
#' Column names and date formats (`dd/mm/yyyy`) are kept as distributed by
#' the source. More information: <https://atlasdigital.mdr.gov.br>.
#'
#' @return
#' A `data.table` with one row per disaster record.
#'
#' @seealso
#' [municipality], [mun_stations], [read_inmet()]
#'
#' @examples
#' \dontrun{
#'
#' disasters <- download_disasters()
#'
#' ## Keep the CSV file locally
#' disasters <- download_disasters(dest_dir = "./data/raw/")
#'
#' }
#'
#' @importFrom utils download.file
#' @export

download_disasters <- function(dest_dir = NULL) {

  old_options <- options(timeout = max(getOption("timeout"), 600))
  on.exit(options(old_options), add = TRUE)

  # https://atlasdigital.mdr.gov.br/paginas/institucional.xhtml
  # https://atlasdigital.mdr.gov.br/paginas/downloads.xhtml

  x  <- "https://atlasdigital.mdr.gov.br/arquivos/2026/BD_Atlas_1991_2025_v1.1_2026.08.06_Consolidado.csv"

  if (!is.null(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
    csv_path <- file.path(dest_dir, basename(x))

    if (!check_file(csv_path)) {
      download.file(x, destfile = csv_path, mode = "wb")
    }
    x <- csv_path
  }

  data.table::fread(x, encoding = "Latin-1")

}
