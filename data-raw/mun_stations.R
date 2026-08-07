
library(climateBR)

#############################################################################
#############################################################################

data("municipality")
data("inmet_stations")

colnames(inmet_stations)

mun_stations <- nearest_stations(
  municipality = municipality,
  inmet_stations = inmet_stations,
  n = 5
)

usethis::use_data(
  mun_stations,
  overwrite = TRUE
)
