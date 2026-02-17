library(fs)
library(here)
library(sf)
library(ggplot2)
library(tidyverse)
library(maps)
library(rnaturalearth)
#-------------------------------------------------------------------------------
source("R/load_data.R")
#source("R/utils/helper_functions.R")
#source("R/utils/plot_functions.R")
ca_map <- map_data("state", region = "california")
usa <- ne_states(country = "united states of america", returnclass = "sf")
ca <- usa[usa$name == "California", ]
plot_folder <- path(here(), "assets", "plots" ,"eda")
dir_create(plot_folder)
noaa_burn_cause <- "Heavy Rain / Burn Area"
period <- paste0(conf$start_year," - ", conf$end_year)
theme_set(theme_minimal())

#-------------------------------------------------------------------------------
# map total events
ggplot() +
  geom_sf(data = ca_eco_l3, aes(fill = name), alpha = 0.2) +
  geom_sf(data = burnt_area, color = "grey") +
  geom_sf(data = fires,
          aes(shape = "Fire"), color = "red", shape = 19, size = 0.1, alpha = 0.4) +
  geom_sf(data = debris |>
            filter(cause == noaa_burn_cause),
          aes(shape = "Debris Flow"), color = "black", size = 1.5, shape = 18, alpha = 0.8) +
  geom_sf(data = floods |>
            filter(cause == noaa_burn_cause),
          aes(shape = "Flash Flood"), color = "blue", size = 1.5, shape = 17, alpha = 0.8) +
  xlab("Latitude") +
  ylab("Longitude") +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 5),      # Smaller text
    legend.title = element_text(size = 6),     # Smaller title
    legend.key.size = unit(0.2, "cm")          # Smaller boxes
  ) +
  guides(fill = guide_legend(
    ncol = 2,                                   # 3 columns
    title = "Ecoregion",
    override.aes = list(alpha = 0.7)           # More visible in legend
  ))
ggsave(path(plot_folder, "map_total_events.png"))


# counts over time
bind_rows(
  debris %>% mutate(type = "debris"),
  floods %>% mutate(type = "flood"),
  fires  %>% mutate(type = "fire")
) %>%
  mutate(period = floor_date(date, unit = "month")) %>%
  count(type, period) %>%
  group_by(type) %>%
  mutate(n_scaled = (n - min(n)) / (max(n) - min(n))) %>%
  ungroup() |>
  mutate(type = factor(type, levels = c("fire", "debris", "flood"))) |>
  ggplot(aes(x = period, y = n, fill = type)) +
  geom_col(alpha = 0.85) +
  facet_wrap(~ type, ncol = 1, scales = "free_y") +
  scale_fill_manual(values = c("debris" = "black", "flood" = "blue", "fire" = "red")) +
  ylab("Count") +
  xlab("Time") + 
  theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(path(plot_folder, "time_count_per_type.png"))
#-------------------------------------------------------------------------------