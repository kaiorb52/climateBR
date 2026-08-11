
library(tidyverse)
library(climateBR)

###################
###################

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

