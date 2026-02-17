library(fs)
library(here)
library(yaml)
library(checkmate)
library(sf)
library(terra)
library(spatstat)
library(tidyverse)
#-------------------------------------------------------------------------------
root <- here()
conf <- yaml::read_yaml(path(root, "conf", "data_processing.yaml"))
dir_prep <- path(root, conf[["path_data_preprocessed"]])
#-------------------------------------------------------------------------------
ca_eco_13_folder <- path(root, "assets", "ca_eco_l3")
ca_eco_shape <- path(ca_eco_13_folder, "ca_eco_l3.shp")
checkmate::assertDirectoryExists(ca_eco_13_folder)
checkmate::assertFileExists(ca_eco_shape)
ca_eco_l3 <- st_read(ca_eco_shape, quiet = TRUE)
ca_eco_l3 <- st_transform(ca_eco_l3, conf[["crs"]])
names(ca_eco_l3)[names(ca_eco_l3) == "NA_L3NAME"] <- "name"

ca_eco_l3 <- ca_eco_l3[, c("geometry", "name")]
ca_window <-  as.owin(st_union(ca_eco_l3))
#-------------------------------------------------------------------------------
# CalFire
checkmate::assertFileExists(path(dir_prep, "fires.gpkg"))
fires <- read_sf(path(dir_prep, "fires.gpkg"))
fires <- fires |>
  st_transform(crs = conf$crs) |>
  filter(year(date) >= conf$start_year, year(date) <= conf$end_year)
fires_ppp <- ppp(
  x = st_coordinates(fires)[, 1],
  y = st_coordinates(fires)[, 2],
  window = ca_window
)

# NOAA debrisflow
checkmate::assertFileExists((path(dir_prep, "debrisflows.gpkg")))
debris <- read_sf(path(dir_prep, "debrisflows.gpkg"), quiet = TRUE)
debris <- debris  |>
  st_transform(crs = conf$crs) |>
  filter(year(date) >= conf$start_year, year(date) <= conf$end_year)
debris_ppp <- ppp(
  x = st_coordinates(debris)[, 1],
  y = st_coordinates(debris)[, 2],
  window = ca_window
)

# NOAA flashfloods
checkmate::assertFileExists(path(dir_prep, "flashfloods.gpkg"))
floods <- read_sf(path(dir_prep, "flashfloods.gpkg"), quiet = TRUE)
floods <- floods |>
  st_transform(crs = conf$crs) |>
  filter(year(date) >= conf$start_year, year(date) <= conf$end_year)
floods_ppp <- ppp(
  x = st_coordinates(floods)[, 1],
  y = st_coordinates(floods)[, 2],
  window = ca_window
)

checkmate::assertFileExists(path(dir_prep, "burnt_area.gpkg"))
burnt_area <- read_sf(path(dir_prep, "burnt_area.gpkg"), quiet = TRUE)

checkmate::assertFileExists(path(dir_prep, "prism.tif"))
prism <- rast(path(dir_prep, "prism.tif"))

total_events <- rbind(
  fires |> st_intersection(ca_eco_l3) |> select(date) |> mutate(event = "fire"),
  debris |> st_intersection(ca_eco_l3) |> select(date) |> mutate(event = "debris"),
  floods |> st_intersection(ca_eco_l3) |> select(date) |> mutate(event = "flood")
)
events_ppp <- ppp(x = st_coordinates(total_events)[, 1],
                  y = st_coordinates(total_events)[, 2],
                  window = ca_window)

#-------------------------------------------------------------------------------
rm(list = c("dir_prep", "root", "ca_eco_13_folder", "ca_eco_shape"))