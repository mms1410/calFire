library(sf)
library(terra)
library(checkmate)
library(yaml)
library(here)
library(fs)
library(zoo)
#-------------------------------------------------------------------------------
root <- here::here()
conf_data <- yaml::read_yaml(path(root, "conf", "data.yaml"))
conf_paths <- yaml::read_yaml(path(root, "conf", "paths.yaml"))
source <- path(root, conf_paths[["data_raw"]], "mod13")
destination <- path(root, conf_paths[["data_preprocessed"]])
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
idx_ndvi <- names(ndvi)[substring(names(ndvi), 1, 4) %in% conf$start_year:conf$end_year]
ndvi <- subset(ndvi, idx_ndvi)

evi <- rast(rast_list_evi)
idx_evi <- names(evi)[substring(names(evi), 1, 4) %in% conf$start_year:conf$end_year]
evi <- subset(evi, idx_evi)

writeRaster(evi, path(destination, "evi.tif"), overwrite = TRUE)
writeRaster(ndvi, path(destination, "ndvi.tif"), overwrite = TRUE)
#-------------------------------------------------------------------------------
agg_rast_yearly <- function(ra, agg_func = mean){
  yearly_list <- list()
  ym <- names(ra)
  y_group <- split(ym, substring(ym, 1, 4))
  for (year in names(y_group)) {
    idx <- ym %in% y_group[[year]]
    monthly_ra <- subset(ra, idx)
    rast_agg <- app(monthly_ra, fun = agg_func, na.rm = TRUE)
    yearly_list[[year]] <- rast_agg
  }
  final_raster <- rast(yearly_list)
  names(final_raster) <- names(y_group)
  dates <- as.Date(paste0(names(y_group), "-01-01"))
  checkmate::assert(length(dates) == nlyr(final_raster))
  terra::time(final_raster) <- dates
  final_raster
}

ndvi_agg <- agg_rast_yearly(ndvi)
evi_agg <- agg_rast_yearly(evi)

writeRaster(ndvi_agg, path(destination, "mdvi_agg.tif"), overwrite = TRUE)
writeRaster(evi_agg, path(destination, "evi_agg.tif"), overwrite = TRUE)
#-------------------------------------------------------------------------------
rm(list = ls())