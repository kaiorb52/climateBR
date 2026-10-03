
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

download_apac(
  years   = 2026,
  dest_dir = "tests/apac/"
)

apac <- list.files("tests/apac/", full.names = TRUE)

list_apac <- list()
for(x in apac){
  list_apac[[x]] <- data.table::fread(x, encoding = "Latin-1", na.strings = "-")
}

library(tidyverse)

list_apac |> 
  bind_rows() |> 
  janitor::clean_names() |> 
  pivot_longer(`x01`:`x31`, names_to = "dia") |> 
  filter(value != "-") |> 
  mutate(
    acumulado = stringi::stri_replace(acumulado, regex = "[,]", ".") |> 
      as.numeric(),
    value = stringi::stri_replace(value, regex = "[,]", ".") |> 
      as.numeric(),
    dia = stringi::stri_replace(dia, regex = "^x", "") |> 
      as.numeric()
  ) |> 
  filter(m_aas_ano == "mai/2026", dia == 1)  |> 
  mutate(
    p_mes = value/acumulado * 100
  ) |> 
  View()


