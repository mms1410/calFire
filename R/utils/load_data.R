library(fs)
library(here)
library(yaml)
library(checkmate)
library(sf)
library(terra)
library(spatstat)
library(tidyverse)
library(ggplot2)
#-------------------------------------------------------------------------------
root <- here()
conf_path <- yaml::read_yaml(path(root, "conf", "paths.yaml"))
conf_data <- yaml::read_yaml(path(root, "conf", "data.yaml"))
crs <- conf_data$crs
directory_prep <- path(root, conf_path[["path_data_preprocessed"]])
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------dem
# CalFire

#'
#'
#'
get_fires <- function(directory = path(here(), "data", "preprocessed")) {
  
  filename <- paste0("fires_", conf_data$start_year, "-", conf_data$end_year, ".gpkg")
  checkmate::assertFileExists(path(directory, filename))
  
  fires <- read_sf(path(directory, filename))
  fires <- fires |>
    st_transform(crs = conf_data$crs) |>
    filter(year(date) >= conf_data$start_year, year(date) <= conf_data$end_year)
  return(fires)
}
# NOAA debrisflow

#'
#'
#'
get_debris <- function(directory = path(here(), "data", "preprocessed")) {
  
  filename <- paste0()
  debris_file <- path(directory, "debrisflows.gpkg")
  checkmate::assertFileExists(debris_file)
  
  debris <- read_sf(debris_file, quiet = TRUE)
  debris <- debris  |>
    st_transform(crs = conf$crs) |>
    filter(year(date) >= conf$start_year, year(date) <= conf$end_year)
  return(debris)
}

# NOAA flashfloods

#'
#'
#'
get_floods <- function(directory = path(here(), "data", "preprocessed")) {
  
  floods_file <- path(directory, "flashfloods.gpkg")
  checkmate::assertFileExists(floods_file)
  
  floods <- read_sf(floods_file, quiet = TRUE)
  floods <- floods |>
    st_transform(crs = conf$crs) |>
    filter(year(date) >= conf$start_year, year(date) <= conf$end_year)
  return(floods)
}

#'
#'
#'
get_total_events <- function(directory = path(here(), "data", "preprocessed")) {
  
  fires <- get_fires(directory)
  debris <- get_debris(directory)
  floods <- get_floods(directory)
  ca <- get_ca()
  ca <- st_transform(ca, st_crs(fires))
  
  rbind(
    fires |> st_intersection(ca) |> select(date) |> mutate(event = "fire"),
    debris |> st_intersection(ca) |> select(date) |> mutate(event = "debris"),
    floods |> st_intersection(ca) |> select(date) |> mutate(event = "flood")
  )
}
#-------------------------------------------------------------------------------
# Other data
get_burnt_area <- function(directory = path(here(), "data", "preprocessed")) {
  
  filename <- paste0("area_", conf_data$start_year, "-", conf_data$end_year, ".gpkg")
  checkmate::assertFileExists(path(directory, filename))
  read_sf(path(directory, filename), quiet = TRUE)
}

get_ndvi <- function(directory = path(here(), "data", "preprocessed")) {
  
  checkmate::assertFileExists(path(directory, "ndvi.tif"))
  rast(path(directory, "ndvi.tif"))
}

get_percipitation <- function(directory = path(here(), "data", "preprocessed")) {
  
  checkmate::assertFileExists(path(directory, "prism.tif"))
  rast(path(directory, "prism.tif"))
}

get_dem <- function(directory = path(here(), "data", "preprocessed")) {
  
  checkmate::assertFileExists(path(directory, "dem.tif"))
  out <- rast(path(directory, "dem.tif"))
  out <- project(out ,crs(conf_data$crs))
}

get_ecozones <- function(directory = path(here(), "assets", "ca_eco_l3")) {
  ca_eco_shape <- path(directory, "ca_eco_l3.shp")
  ca_eco_l3 <- st_read(ca_eco_shape, quiet = TRUE)
  ca_eco_l3 <- st_transform(ca_eco_l3, conf_data[["crs"]])
  names(ca_eco_l3)[names(ca_eco_l3) == "NA_L3NAME"] <- "name"
  ca_eco_l3[, c("geometry", "name")]
  ca_eco_l3 <- st_transform(ca_eco_l3, crs)
}

get_prism_ts <- function(directory = path(here(), "data", "intermediate"), date_col = TRUE) {
  out <- read.csv(path(directory, "ts_prism.csv"))
  if (date_col) {
    out <- out |>
      mutate(date = as.Date(paste0(year, "-", month, "-01"))) |>
      select(-c(year, month))
  }
  out
}

get_ca <- function() {
  ca_map <- ggplot2::map_data("state", region = "california")
  usa <- rnaturalearth::ne_states(country = "united states of america", returnclass = "sf")
  ca <- usa[usa$name == "California", ]
  ca <- st_transform(ca, crs)
}
#-------------------------------------------------------------------------------
rm(list = c("directory_prep", "root"))