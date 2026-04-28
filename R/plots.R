source("R/utils/load_data.R")
source("R/utils/plot_functions.R")
source("R/utils/helper_functions.R")
#-------------------------------------------------------------------------------
library(fs)
library(here)
library(sf)
library(ggplot2)
library(tidyverse)
#-------------------------------------------------------------------------------
plot_folder <- path(here(), "assets", "plots")
dir_create(plot_folder)
noaa_burn_cause <- "Heavy Rain / Burn Area"
period <- paste0(conf_data$start_year," - ", conf_data$end_year)
#-------------------------------------------------------------------------------
fires <- get_fires()
burnt_area <- get_burnt_area()
ca_eco_l3 <- get_ecozones()
ca <- get_ca()
#-------------------------------------------------------------------------------
########################
# Wildfires Descriptive
#######################
ggplot() +
  get_ca_layer() +
  get_fires_layer() +
  facet_wrap(~ lubridate::year(date)) +
  #ggtitle("Yearly wildfire locations") +
  theme(axis.ticks = element_blank(), axis.text = element_blank()) 
gg_save("fires_yearly", width = NA, height = NA)


ggplot() +
  get_fires_layer() + 
  get_ecoz_layer(legend = TRUE) +
  theme(legend.position = "right") +
  #ggtitle(paste0("Total wildfires by Ecozone ", period)) +
  labs(fill = "")
gg_save("fires_total_ecoz")


ggplot() +
  get_fires_layer(alpha = 0.7) +
  get_ecoz_layer() +
  theme(axis.ticks = element_blank(), axis.text = element_blank()) +
  facet_wrap(~ lubridate::year(date))
gg_save("fires_yearly_ecoz")


## time series total wildfires
fires |>
  get_count_ts() |>
  ggplot() +
  geom_line(aes(x = time, y = count)) +
  # ggtitle(paste0("Monthly wildfire counts ", period)) +
  xlab("Year and Month")
gg_save("ts_wildfire_counts")


## time series total wildfires ecozone
fires |>
  st_join(ca_eco_l3) |>
  mutate(year = lubridate::year(date), month = lubridate::month(date)) |>
  group_by(year, month, name) |>
  summarize(count = n()) |>
  mutate(year_month = as.Date(paste0(year, "-", month, "-", 1))) |>
  select(c(year_month, count, name)) |>
  ggplot() +
  geom_line(aes(x = year_month, y = count, color = name)) +
  #ggtitle(paste("Monthly wildfire counts ", period, "by ecological region")) +
  xlab("Month")
gg_save("ts_wildfire_counts_ecoz")
#-------------------------------------------------------------------------------
#######################
# Wildfires Exploratory
#######################
library(spatstat)
library(ggdensity)

fires_pp <- ppp(x = st_coordinates(fires)[,1],
                y = st_coordinates(fires)[,2],
                window = as.owin(ca)) #as.owin(st_transform(ca, 3310)))

density(fires_pp, sigma = bw.ppl(fires_pp), at = "pixels") |> 
  as.data.frame() |>
  ggplot(aes(x = x, y = y, fill = value)) +
  geom_raster() +
  scale_fill_viridis_c() +
  ylab("Latiude") +
  xlab("Longitude") +
  labs(fill = "Density") +
  #ggtitle(paste0("Density estimation Wildfires ", conf_data$start_year, "-", conf_data$end_year)) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank())
ggsave(path(here(), "assets", "plots", "density_wildfires_total.png"), dpi = 300)
#-------------------------------------------------------------------------------
ym_names <- function(names) {
  format(ym(names), "%Y %b")
}
#######
# NDVI
#######
ndvi <- get_ndvi()
ndvi_names <- ym_names(names(ndvi))
raster_to_pngs(ndvi,
               destination_dir = path(plot_folder, "ndvi"),
               raster_names = ndvi_names)
pngs_to_gif(path(plot_folder, "ndvi"),
            path(plot_folder, "ndvi.gif"),
            ndvi_names)
###############
# Percipitation
###############
percpt <- get_percipitation()
percp_names <- ym_names(names(percpt))
raster_to_pngs(percpt,
               path(plot_folder, "percp"),
               percp_names)

plot_prism_total <- function(prism_folder, yearls = TRUE) {
  
}