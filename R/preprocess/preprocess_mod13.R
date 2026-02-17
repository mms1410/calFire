library(sf)
library(terra)
library(checkmate)
library(yaml)
library(here)
library(fs)
library(zoo)
#-------------------------------------------------------------------------------
root <- here::here()
conf <- yaml::read_yaml(path(root, "conf", "data_processing.yaml"))
source <- path(root, conf[["path_data_raw"]], "mod13")
destination <- path(root, conf[["path_data_preprocessed"]])
#-------------------------------------------------------------------------------
all_files <- dir_ls(source)
ndvi_files <- grep("NDVI.*\\.tif$", all_files, value = TRUE)
evi_files <- grep("NDVI.*\\.tif$", all_files, value = TRUE)

years_ndvi <- sub(".*doy([0-9]{4}).*", "\\1", ndvi_files)
years_evi <- sub(".*doy([0-9]{4}).*", "\\1", evi_files)

ndvi_files_grouped <- split(ndvi_files, years_ndvi)
evi_files_grouped <- split(evi_files, years_evi)

checkmate::assert(all(names(ndvi_files_grouped) == names(evi_files_grouped)))

rast_list_ndvi <- list()
rast_list_evi <- list()
for (year in names(ndvi_files_grouped)) {
  # apply rast for each file and each month to retrieve a raster for year
  # with n_month layers

  jul_day <- sub(".*doy([0-9]{4})([0-9]{3}).*", "\\2", ndvi_files_grouped[[year]])
  dates <- as.Date(paste(year, jul_day), format = "%Y%j")
  
  yearly_ndvi <- rast(lapply(ndvi_files_grouped[[year]], rast))
  yearly_evi <- rast(lapply(evi_files_grouped[[year]], rast))
  
  terra::time(yearly_evi) <- dates
  terra::time(yearly_ndvi) <- dates
  
  names(yearly_evi) <- format(dates, "%Y %B")
  names(yearly_ndvi) <- format(dates, "%Y %B")
  
  rast_list_ndvi[[year]] <- yearly_ndvi
  rast_list_evi[[year]] <- yearly_evi
}
ndvi <- rast(rast_list_ndvi)
evi <- rast(rast_list_evi)

writeRaster(evi, path(destination, "evi.tif"))
writeRaster(ndvi, path(destination, "ndvi.tif"))
#-------------------------------------------------------------------------------
rm(list = ls())