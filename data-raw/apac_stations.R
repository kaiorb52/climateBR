
library(tidyverse)

#############################################################################
#############################################################################

r <- httr::GET("https://api.apac.pe.gov.br/api.php/estacoes?operador=Todos")
json <- httr::content(r, as = "text", encoding = "UTF-8")

apac_raw <- jsonlite::fromJSON(json)

mun_pe <- geobr::read_municipality(code_muni = "PE", year = 2024) |>
  sf::st_drop_geometry() |>
  transmute(
    code_ibge7 = as.numeric(code_muni),
    key        = tolower(stringi::stri_trans_general(name_muni, "Latin-ASCII"))
  )

#############################################################################
#############################################################################

apac_stations <- apac_raw |>
  mutate(
    across(where(is.character), \(x) na_if(str_squish(x), "")),
    key = tolower(stringi::stri_trans_general(nome_municipio, "Latin-ASCII"))
  ) |>
  left_join(mun_pe, by = "key") |>
  transmute(
    code_apac         = identificador,        
    code_gmmc         = codigo_gmmc,
    station_name      = estacao,
    station_type      = recode(
      sigla_tipo_estacao,
      V = "Conventional rain gauge",
      A = "Automatic rain gauge",
      M = "Meteorological station",
      H = "Hydrological station",
      U = "Agrometeorological station",
      C = "Acqua station"
    ),
    status            = recode(
      status_estacao,
      Ativo      = "active",
      Inativo    = "inactive",
      Manutenção = "maintenance"
    ),
    operator          = operador,
    owner             = nome_proprietario,
    state_station     = "PE",
    code_ibge7,
    name_muni         = nome_municipio,
    location          = na_if(local_instalacao, "não identificado"),
    manufacturer      = na_if(fabricante, "NÃO IDENTIFICADO"),
    model             = modelo,
    lat               = latitude,
    lon               = longitude
  ) |>
  mutate(
    invalid = !(between(lat, -9.6, -3.7) & between(lon, -41.5, -32.3)),
    lat     = if_else(invalid, NA_real_, lat),
    lon     = if_else(invalid, NA_real_, lon)
  ) |>
  select(-invalid) |>
  arrange(code_ibge7, code_gmmc) |>
  as_tibble()

stopifnot(!anyNA(apac_stations$code_ibge7))

#############################################################################
#############################################################################

usethis::use_data(
  apac_stations,
  overwrite = TRUE
)
