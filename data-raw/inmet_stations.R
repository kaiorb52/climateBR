
library(tidyverse)

#############################################################################
#############################################################################

lista_df <- list()
for (x in 2000:2026){
  print(x)
  list_ano <- list()
  
  for (f in list.files(glue::glue("raw/inmet/{x}/"), full.names = TRUE)) {

    df <- data.table::fread(f, nrows = 5, encoding = "Latin-1") |>
      pivot_wider(names_from = 1, values_from = 2) |>
      janitor::clean_names() |> 
      mutate(
        ano = x
      )

    list_ano[[f]] <- df

  }
  lista_df[[x]] <- list_ano |> 
    bind_rows()
}

df_final <- lista_df |> 
  bind_rows()

inmet_stations <- df_final |> 
  select(
    state_station   = uf, 
    code_wmo = codigo_wmo,
    lat     = latitude, 
    lon    = longitude, 
    ano
  ) |> 
  group_by(code_wmo) |> 
  mutate(
    lat = stringi::stri_replace(lat, regex = ",", replacement = ".") |> 
      as.numeric(),
    lon = stringi::stri_replace(lon, regex = ",", replacement = ".") |> 
      as.numeric(),
    creation_year  = min(ano),
    last_used_year = max(ano), 
    last_used_year = ifelse(last_used_year == 2026, NA, last_used_year)
  ) |> 
  distinct(state_station, code_wmo, .keep_all = TRUE) |> 
  select(-ano)

usethis::use_data(
  inmet_stations,
  overwrite = TRUE
)

