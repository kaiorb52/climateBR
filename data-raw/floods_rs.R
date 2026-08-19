
library(dplyr)
library(tidyr)
library(climateBR)

#---------------------------------------------------------------------------#

data("inmet_stations")

download_inmet(
  years = 2020,
  unzip_to = "~/inmet/raw/"
)

build_inmet_dataset(
  years = 2024,
  input  = "~/inmet/raw/",
  output = "~/inmet/processed/" 
)

inmet_2024 <- read_inmet(
  path = "~/inmet/processed/"
)

floods_rs <- inmet_2024 |> 
  mutate(
    precipitacao_total_horario_mm = ifelse(precipitacao_total_horario_mm <= -9999, 0, precipitacao_total_horario_mm),
    data_yyyy_mm_dd = as.character(data_yyyy_mm_dd)
  ) |> 
  filter(
    data_yyyy_mm_dd %in% c(
      "2024-04-27", "2024-04-28", "2024-04-29", "2024-04-30",
      "2024-05-01", "2024-05-02", "2024-05-03", "2024-05-04", "2024-05-05"
    )
  ) |>
  group_by(codigo_wmo) |>
  summarise(
    total_rainfall = sum(precipitacao_total_horario_mm, na.rm = TRUE)
  ) |> 
  filter(!is.na(total_rainfall) & !is.infinite(total_rainfall)) |> 
  left_join(
    inmet_stations |> 
      select(code_wmo, lat, lon),
      by = c("codigo_wmo" = "code_wmo")
  ) |> 
  select(code_wmo = codigo_wmo, lat, lon, total_rainfall) |> 
  collect()

#############################################################################
#############################################################################

usethis::use_data(
  floods_rs,
  overwrite = TRUE
)
