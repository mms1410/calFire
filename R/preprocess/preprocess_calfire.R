library(sf)
library(here)
library(fs)
library(yaml)
#-------------------------------------------------------------------------------
conf_path <- yaml::read_yaml(path(here(), "conf", "paths.yaml"))
conf_data <- yaml::read_yaml(path(here(), "conf", "data.yaml"))
dir_raw_calfire <- path(here(), conf_path[["data_raw"]], "calfire")
dir_preprocessed <- path(here(), conf_path[["data_preprocessed"]])
filename_source <- paste0("calfire_", conf_data[["start_year"]], "-", conf_data[["end_year"]], ".gpkg")
filename_fires <- paste0("fires_", conf_data[["start_year"]], "-", conf_data[["end_year"]], ".gpkg")
filename_area <- paste0("area_", conf_data[["start_year"]], "-", conf_data[["end_year"]], ".gpkg")
#-------------------------------------------------------------------------------
calfire <- st_read(path(dir_raw_calfire, filename_source))
calfire <- calfire[calfire$OBJECTIVE == "Suppression (Wildfire)",]
calfire <- calfire[!is.na(calfire$Shape__Area) & !is.na(calfire$ALARM_DATE),]

calfire$geom <- st_make_valid(calfire$geom)
calfire$area <- st_area(calfire$geom)
calfire$centroid <- st_centroid(calfire$geom)
calfire$date <- as.POSIXct(calfire$ALARM_DATE / 1000,  # time in milisec since origin
                   origin = "1970-01-01",
                   tz = "UTC")
ca <- USAboundaries::us_states(resolution = "high", states = "CA")
calfire <- calfire[st_within(calfire, ca, sparse = FALSE), ]

cnames <- c("OBJECTID" = "id", "geom" = "burnt_area")
names(calfire)[match(names(cnames), names(calfire))] <- cnames

st_geometry(calfire) <- "burnt_area"
burnt_area <- calfire[, c("id", "date", "burnt_area")] |>
  na.omit() |>
  st_transform(crs = conf_data[["crs"]])

st_geometry(calfire) <- "centroid"
fires <- calfire[, c("id", "date", "centroid")] |>
  na.omit() |>
  st_transform(crs = conf_data[["crs"]])

st_write(burnt_area, path(dir_preprocessed, filename_area), append = FALSE)
st_write(fires, path(dir_preprocessed, filename_fires), append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())