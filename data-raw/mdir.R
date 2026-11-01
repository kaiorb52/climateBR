
x <- "https://atlasdigital.mdr.gov.br/arquivos/2026/BD_Atlas_1991_2025_v1.1_2026.08.06_Consolidado.csv"
download.file(x, destfile = "tests/atlas.csv")

atlas <- data.table::fread("tests/atlas.csv", encoding = "Latin-1")
saveRDS(atlas, "BD_Atlas_1991_2025_v1.1_2026.08.06_Consolidado.rds")
# https://zenodo.org/records/23857290/files/BD_Atlas_1991_2025_v1.1_2026.08.06_Consolidado.rds?download=1

#library(climateBR)
#mdir <- download_disasters(dest_dir = "tests/midr_test_nw")

mdir <- download_disasters(dest_dir = "tests/midr_test_nw")
