library(terra)
library(fs)
library(checkmate)
library(here)
library(zip)
library(yaml)
library(sf)
#-------------------------------------------------------------------------------
root <- here::here()
nasadem_raw <- fs::path(root, "data", "raw", "nasadem")
checkmate::assertDirectoryExists(nasadem_raw)
ca <- vect(path(root, "assets", "ca_state", "CA_State.shp"))
conf <- yaml::read_yaml(path(root, "conf", "data_processing.yaml"))
crs <- sf::st_crs(conf$crs)
#-------------------------------------------------------------------------------
zip_files <- dir_ls(nasadem_raw, glob = "*.zip")

read_raster <- function(file) {
  content <- zip_list(file)
  hgt_filename <- content$filename[grepl("\\.hgt$", content$filename)]
  rast(paste0("/vsizip/", path(file, hgt_filename)))
}

rasters <- lapply(zip_files, read_raster)
raster_collection <- sprc(rasters)
dem_final <- mosaic(raster_collection)
ca <- project(ca, crs(dem_final))
dem_cropped <- crop(dem_final, ca)
dem_masked  <- mask(ca_cropped, ca)
dem_final <- project(dem_masked, crs$wkt)
writeRaster(ca_masked, path(root, "data", "preprocessed", "dem.tif"))
#-------------------------------------------------------------------------------
rm(list = ls())