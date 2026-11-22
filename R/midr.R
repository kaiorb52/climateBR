#' Download natural disaster records from the Brazilian Atlas of Natural Disasters
#'
#' Downloads the consolidated database of the *Atlas Digital de Desastres no
#' Brasil*, maintained by the Ministry of Integration and Regional Development
#' (MIDR) in partnership with CEPED/UFSC. Each row is a disaster record
#' registered by a municipality in the Integrated Disaster Information System
#' (S2iD) between 1991 and 2025.
#'
#' @param dest_dir Character. Directory where the file is saved
#'   (e.g. `"./data/raw/"`). It is created if it does not exist. If `NULL`
#'   (default), a temporary directory is used.
#'
#' @details
#' Source: Ministry of Integration and Regional Development (MIDR) and
#' CEPED/UFSC, *Atlas Digital de Desastres no Brasil*. More information:
#' <https://atlasdigital.mdr.gov.br>.
#'
#' Each record has the municipality (`Nome_Municipio`, `Sigla_UF` and
#' `Cod_IBGE_Mun`, the 7-digit IBGE code that joins with [municipality] and
#' [mun_stations]), the event date (`Data_Evento`, `dd/mm/yyyy`) and the
#' disaster type according to COBRADE (`Cod_Cobrade`, `descricao_tipologia`
#' and `grupo_de_desastre`, e.g. climatological, hydrological or
#' meteorological). `Status` tells whether the federal government
#' recognized the emergency or public calamity (`"Reconhecido"`) or the
#' event was only registered (`"Registro"`).
#'
#' The impacts reported by the municipality are grouped by column prefix:
#' \describe{
#'   \item{`DH_`}{Human damages: number of dead (`DH_MORTOS`), injured
#'     (`DH_FERIDOS`), sick (`DH_ENFERMOS`), homeless (`DH_DESABRIGADOS`),
#'     displaced (`DH_DESALOJADOS`) and missing (`DH_DESAPARECIDOS`).}
#'   \item{`DM_`}{Material damages: damaged and destroyed housing, health,
#'     education and infrastructure units, and their value in BRL
#'     (e.g. `DM_Uni Habita Destruidas`, `DM_total_danos_materiais`).}
#'   \item{`DA_`}{Environmental damages, such as water, air and soil
#'     pollution, as a share of the affected population.}
#'   \item{`PEPL_`}{Public economic losses in BRL, by sector (e.g. health
#'     care, water supply, energy), with the total in `PEPL_total_publico`.}
#'   \item{`PEPR_`}{Private economic losses in BRL (agriculture, livestock,
#'     industry, commerce and services), with the total in
#'     `PEPR_total_privado`.}
#' }
#'
#' If the file already exists in `dest_dir`, it is read from disk instead of
#' being downloaded again. If it is corrupted (e.g. after an interrupted
#' download), delete it and run the function again.
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
#' ## Keep the file locally
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

  x  <- "https://zenodo.org/records/23857290/files/BD_Atlas_1991_2025_v1.1_2026.08.06_Consolidado.rds"

  if (is.null(dest_dir)) {
    dest_dir <- tempfile()
  }
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  arq_path <- file.path(dest_dir, basename(x))

  if (check_file(arq_path)) {
    message("File already exists in '", dest_dir, "', reading it from disk.")
  } else {
    # Remove partial files so a failed download is not reused as cache
    tryCatch(
      download.file(x, destfile = arq_path, mode = "wb"),
      error = function(e) {
        unlink(arq_path)
        stop(e)
      }
    )
  }

  readRDS(arq_path)

}
