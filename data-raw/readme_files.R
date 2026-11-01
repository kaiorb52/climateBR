
library(tidyverse)
library(climateBR)

###################
###################
# INMET RJ 2026

download_inmet(
  years = 2026,
  unzip_to = "~/data/raw/inmet"
)

build_inmet_dataset(
  input = "~/data/raw/inmet/",
  output = "~/data/processed/inmet/"
)

df_inmet <- read_inmet(path = "~/data/processed/inmet")

data("mun_stations")

temp_rj <- df_inmet |> 
  group_by(ano, mes, codigo_wmo) |> 
  summarise(
    temp_max = max(temperatura_maxima_na_hora_ant_aut_c, na.rm = TRUE)
  ) |> 
  left_join(
    mun_stations |> filter(station_order == 1) |> select(state_muni, code_ibge7, code_wmo), 
    by = c("codigo_wmo" = "code_wmo")
  ) |> 
  filter(state_muni == "RJ") |> 
  collect() |> 
  arrange(-temp_max)

boxplot_temp_rj <- temp_rj |> 
  ggplot(aes(x = as.character(mes), y = temp_max)) +
  geom_boxplot() +
  theme_linedraw() +
  labs(y = "Max. Temp (Cº)", x = "Month") +
  ylim(20, 40)

ggsave(plot = boxplot_temp_rj, filename = "man/figures/boxplot_temp_rj.png", height = 7, width = 10)

###########################
mun_24 <- geobr::read_municipality(year = 2024)

mun_rj <- mun_24 |> 
  filter(abbrev_state == "RJ") |> 
  select(code_muni, geom)

mun_temp_rj <- mun_rj |> 
  left_join(
    temp_rj, 
    by = c("code_muni" = "code_ibge7")
  )

mun_temp_rj$mes <- factor(
  mun_temp_rj$mes,
  levels = 1:12,
  labels = month.name
)

map_temp_rj <- ggplot() +
  geom_sf(data = mun_temp_rj, aes(fill = temp_max)) +
  scale_fill_distiller(palette = "RdYlGn") +
  facet_wrap(.~mes) +
  labs(fill = "Max. Temp (Cº)") +
  theme_void() +
  theme(
    legend.position = c(0.785, 0.185),
    plot.background = element_rect(fill = "white")
  )

ggsave(plot = map_temp_rj, filename = "man/figures/map_temp_rj.png", height = 7, width = 10)

###################
###################
# MDIR

options(scipen = 999)

mdir <- download_disasters(
  dest_dir = "tests/mdir/" 
)

mdir |> 
  mutate(
    ano = stringi::stri_extract(Data_Evento, regex = "\\d{4}$")
  ) |> 
  group_by(ano) |> 
  summarise(
    n = n(),
    DH_afetados = sum(DH_MORTOS) + sum(DH_DESAPARECIDOS) + sum(DH_DESABRIGADOS) + sum(DH_DESALOJADOS)
  ) |> 
  ggplot(aes(x = as.numeric(ano), y = DH_afetados)) +
  geom_point(
    shape = 18,
    size  = 3
  ) +
  geom_line() +
  geom_smooth(se = FALSE, color = "firebrick2") +
  #scale_y_continuous( = scales::number()) +
  scale_x_continuous(breaks = seq(1990, 2025, 5)) +
  labs(
    x = NULL,
    y = "N. de Diretamente Afetados"
  ) +
  theme_classic()

###################
###################
# APAC 2026

library(tidyverse)
library(climateBR)
library(sf)

apac <- download_apac(
  years    = 2026,
  dest_dir = "tests/apac/"
)

data("apac_stations")

apac_flood <- apac |>
  filter(`Mês/Ano` == "mai/2026") |>
  mutate(
    code_apac     = as.character(`Código`)
  ) |>
  select(code_apac, chuva_maio_01 = `01`) |> 
  filter(!is.na(chuva_maio_01)) |>
  inner_join(
    apac_stations |> select(code_apac, station_name, code_ibge7, lat, lon),
    by = "code_apac"
  ) |>
  filter(!is.na(lat), code_ibge7 != 2605459) |>
  distinct(lat, lon, .keep_all = TRUE)

apac_flood_sf <- apac_flood |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

mun_pe <- geobr::read_municipality(code_muni = "PE", year = 2024) |>
  filter(code_muni != 2605459) |>
  select(code_muni, geom) |>
  st_transform(crs = 4326)

krig_pe <- kriging_inmet(
  stations_df = apac_flood_sf,
  mun_geo     = st_centroid(mun_pe),
  var         = "chuva_maio_01"
)

mun_rain_pe <- mun_pe |>
  mutate(chuva_krig = pmax(krig_pe$var1.pred, 0))

map_chuva_pe <- ggplot() +
  geom_sf(data = mun_rain_pe, aes(fill = chuva_krig), color = "grey70", linewidth = 0.1) +
  scale_fill_distiller(palette = "RdYlGn", direction = 1) +
  labs(fill = "Rainfall (mm)\nMay 1, 2026") +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm"),
    plot.background = element_rect(fill = "white", color = NA)
  )

ggsave(plot = map_chuva_pe, filename = "man/figures/map_rain_pe.png", height = 5.2, width = 10, dpi = 300)
