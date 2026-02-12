library(sf)
library(here)
library(fs)
library(yaml)
library(USAboundaries)
#-------------------------------------------------------------------------------
conf <- yaml::read_yaml(path(here(), "conf", "data_processing.yaml"))
dir_raw_calfire <- path(here(), conf$path_data_raw, "calfire")
dir_preprocessed <- path(here(), conf$path_data_preprocessed)
crs <- conf[["crs"]]
q_area <- conf[["quantile_fire_area"]]
#-------------------------------------------------------------------------------
calfire <- st_read(path(dir_raw_calfire, "calfire_2000-2025.gpkg"))
calfire <- calfire[calfire$OBJECTIVE == "Suppression (Wildfire)",]
calfire <- calfire[!is.na(calfire$Shape__Area) & !is.na(calfire$ALARM_DATE),]

calfire$geom <- st_make_valid(calfire$geom)
calfire$area <- st_area(calfire$geom)
calfire$centroid <- st_centroid(calfire$geom)
calfire$date <- as.POSIXct(calfire$ALARM_DATE / 1000,  # time in milisec since origin
                   origin = "1970-01-01",
                   tz = "UTC")
ca <- us_states(resolution = "high", states = "CA")
calfire <- calfire[st_within(calfire, ca, sparse = FALSE), ]

cnames <- c("OBJECTID" = "id", "geom" = "burnt_area")
names(calfire)[match(names(cnames), names(calfire))] <- cnames

st_geometry(calfire) <- "burnt_area"
calfire[, c("id", "date", "burnt_area")] |>
  na.omit() |>
  st_write(path(dir_preprocessed, "burnt_area.gpkg"), append = FALSE)

st_geometry(calfire) <- "centroid"
calfire[, c("id", "date", "centroid", "area")] |>
  na.omit() |>
  st_write(path(dir_preprocessed, "fires.gpkg"), append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())