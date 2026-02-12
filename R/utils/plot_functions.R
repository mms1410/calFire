library(ggplot2)
library(USAboundaries)
library(lubridate)
library(sf)
#-------------------------------------------------------------------------------
source("R/load_data.R")
ca <- us_states(resolution = "high", states = "CA")
theme_set(theme_minimal())
options(
  ggplot2.discrete.colour = scale_colour_viridis_d(),
  ggplot2.discrete.fill   = scale_colour_viridis_c()
)
#-------------------------------------------------------------------------------
geom_l3_ca <- function(){
  list(
    geom_sf(data = ca_eco_l3, aes(fill = US_L3NAME), alpha = 0.5)
  )
}

ggplot() +
  geom_sf(data = burnt_area[st_within(burnt_area, ca, sparse = FALSE), ])
