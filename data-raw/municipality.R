
library(tidyverse)
library(sf)

#############################################################################
#############################################################################

codigos <- read.csv("~/git/dados_municipais/reference/codigos.csv")
mun_24 <- geobr::read_municipality(year = 2024)

#############################################################################
#############################################################################

codigos2 <- codigos |> 
  select(
    state      = sigla_uf,
    code_ibge7 = id_municipio, 
    code_ibge6 = id_municipio_6, 
    code_tse   = id_municipio_tse
  )

mun_24_lat <- mun_24 |> 
  select(code_muni, geom) |>
    mutate(
      centro = st_point_on_surface(geom),
      lon = unlist(st_coordinates(centro)[, 1]),
      lat = unlist(st_coordinates(centro)[, 2]),
    ) |>
  select(-centro) |> 
  st_drop_geometry()

municipality <- codigos2 |> 
  left_join(
    mun_24_lat,
    by = c("code_ibge7" = "code_muni")
  )

#############################################################################
#############################################################################

save(municipality, file = "data/municipality.rda")
