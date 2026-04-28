library(esri2sf)
library(sf)
library(here)
library(fs)
library(yaml)
#-------------------------------------------------------------------------------
conf_data <- yaml::read_yaml(path(here(), "conf", "data.yaml"))
conf_path <- yaml::read_yaml(path(here(), "conf", "paths.yaml"))
dir_destination <- path(here(), conf_path[["data_raw"]], "calfire")
start_year <- conf_data[["start_year"]]
end_year <- conf_data[["end_year"]]
crs <- conf_data[["crs"]]
arcgis_url_fires <- conf_data[["url_fires"]]
#-------------------------------------------------------------------------------
dir_create(dir_destination)

where <- paste0("YEAR_ >= ", start_year, " AND ", "YEAR_ <=", end_year)
fire_layer <- esri2sf(
  arcgis_url_fires,
  where = where
  )
calfire_raw <- path(dir_destination, paste0("calfire_", start_year,"-", end_year, ".gpkg"))
st_write(fire_layer, calfire_raw, append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())