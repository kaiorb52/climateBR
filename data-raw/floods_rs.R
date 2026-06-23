
library(dplyr)
library(tidyr)
library(climateBR)

#---------------------------------------------------------------------------#

load("data/rain_stations.rda")

rain_stations_24 <- rain_stations |>
  filter(ano == 2024) |>
  select(-ano)

climateBR::download_inmet(
  years = 2024
)

lista_df <- list()
for (x in list.files(glue::glue("2024/"), full.names = TRUE)) {
  
  df <- data.table::fread(x, nrows = 6) |>
    pivot_wider(names_from = 1, values_from = 2) |>
    janitor::clean_names() |>
    select(codigo_wmo) |>
    cross_join(
      data.table::fread(x, skip = 7, sep = ";", encoding = "Latin-1") |>
        janitor::clean_names() |>
        mutate(
          across(3:19, ~
                   stringi::stri_replace(.x, regex = "[,]",replacement = ".") |>
                   as.numeric()
          )
        )
    ) |>
    mutate(ano = 2024)
  
  if ("data" %in% c(colnames(df))){
    df <- df |>
      rename(data_yyyy_mm_dd = data)
  }
  
  if ("data" %in% c(colnames(df))){
    df <- df |>
      rename(data_de_fundacao = data)
  }
  
  lista_df[[x]] <- df
  rm(df)
}

floods_rs <- lista_df |> 
  bind_rows() |> 
  mutate(
    precipitacao_total_horario_mm = ifelse(precipitacao_total_horario_mm <= -9999, 0, precipitacao_total_horario_mm),
    data_yyyy_mm_dd = as.character(data_yyyy_mm_dd)
  ) |> 
  filter(
    data_yyyy_mm_dd %in% c(
      "2024/04/27", "2024/04/28", "2024/04/29", "2024/04/30",
      "2024/05/01", "2024/05/02", "2024/05/03", "2024/05/04", "2024/05/05"
    )
  ) |>
  group_by(codigo_wmo) |>
  summarise(
    total_rainfall = sum(precipitacao_total_horario_mm, na.rm = TRUE)
  ) |> 
  left_join(rain_stations_24) |>
  filter(!is.na(total_rainfall) & !is.infinite(total_rainfall)) |>
  select(id_who = codigo_wmo, lat = latitude, long = longitude, total_rainfall)

save(floods_rs, file = "data/floods_rs.rda")
load("data/floods_rs.rda")
