library(sf)
library(ggplot2)
library(tidyverse)
#-------------------------------------------------------------------------------
source("R/load_data.R")
source("R/utils/helper_functions.R")
source("R/utils/plot_functions.R")
noaa_burn_cause <- "Heavy Rain / Burn Area"
# ca size roughly 423,970km^2
fires2 <- fires |>
  slice_max(area, n = 5, with_ties = FALSE)

quantiles <- fires |>
  slice_min(order_by = area, n = n() - 5) |>
  mutate(q = ntile(area, 4))

#-------------------------------------------------------------------------------
ggplot() +
  geom_sf(data = ca_aes(fill = name)) +
  geom_sf(data = burnt_area, fill = "grey73") +
  geom_sf(data = fires,
          aes(shape = "Fire"), color = "red", shape = 19, size = 0.1, alpha = 0.4) +
  geom_sf(data = debris |>
            filter(cause == noaa_burn_cause),
          aes(shape = "Debris Flow"), color = "black", size = 1.5, shape = 18, alpha = 0.8) +
  geom_sf(data = floods |>
            filter(cause == noaa_burn_cause),
          aes(shape = "Flash Flood"), color = "blue", size = 1.5, shape = 17, alpha = 0.8) +
  ggtitle("Wildfire, Debris-flow and Flash-floods locations",
          subtitle = "2000-2025")
ggsave("assets/plots/total_events.png")


count_by_year(fires, floods, debris) |>
  ggplot(aes(x = as.factor(year))) +
  geom_col(aes(y = fires, group = "fires"), fill = "red", position = position_dodge(width = 0.9)) +
  geom_col(aes(y = debris, group = "debris"), fill = "black", position = position_dodge(width = 0.9)) +
  ylab("Count") +
  xlab("")


#-------------------------------------------------------------------------------
ggplot() +
  geom_sf(data = ca_eco_l3, aes(fill = name), alpha = 0.3)

#-------------------------------------------------------------------------------
ggplot() +
  #geom_sf(data = ca_eco_l3, aes(fill = name), alpha = 0.3) +
  geom_sf(data = fires |>
            filter(area_q == 4),
          aes(color = "fire"), color = "red", shape = 3, size = 0.1) +
  geom_sf(data = debris |>
            filter(cause == noaa_burn_cause),
          aes(color = "debris flow"), color = "black", size = 0.8, shape = 7) +
  geom_sf(data = floods |>
            filter(cause == noaa_burn_cause),
          aes(color = "Flash Flood"), color = "blue", size  = 0.8, shape = 9)
#-------------------------------------------------------------------------------
x <- st_transform(burnt_area, 3310) |> st_area() |> as.numeric() 
format(x, scientific = FALSE)


ggplot(fires) +
  geom_histogram(aes(area), bins = 100) + 
  facet_wrap(~area_q)


fires |>
  filter(area_q == 4) |>
  ggplot() + 
  geom_histogram(aes(area))
