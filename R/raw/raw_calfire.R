library(esri2sf)
library(sf)
library(here)
library(fs)
library(yaml)
#-------------------------------------------------------------------------------
conf <- yaml::read_yaml(path(here(), "conf", "config.yaml"))
dir_destination <- path(here(), conf$path_data_raw, "calfire")
start_year <- conf$start_year
end_year <- conf$end_year
crs <- conf$crs
bbox_ca <- st_bbox(unlist(conf$bbox_ca), crs = crs)
arcgis_url_fires <- conf$url_fires
#-------------------------------------------------------------------------------
dir_create(dir_destination)

where <- paste0("YEAR_ >= ", start_year, " AND ", "YEAR_ <=", end_year)
#where <- paste0("YEAR_ >= ", start_year)
fire_layer <- esri2sf(
  arcgis_url_fires,
  bbox = bbox_ca,
  where = where
  )
final_destination <- path(dir_destination, paste0("calfire_", start_year,"-", end_year, ".gpkg"))
st_write(fire_layer, final_destination, append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())