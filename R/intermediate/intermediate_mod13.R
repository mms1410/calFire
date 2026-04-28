library(terra)
library(tidyverse)
library(fs)
library(yaml)
library(here)
#-------------------------------------------------------------------------------
source("R/load_data.R")
#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "data_processing.yaml"))

ndvi <- rast(path(here(), conf[["path_data_preprocessed"]], "ndvi.tif"))
idx_ndvi <- names(ndvi)[substring(names(ndvi), 1, 4) %in% conf$start_year:conf$end_year]
ndvi <- subset(ndvi, idx_ndvi)

evi <- rast(path(here(), conf[["path_data_preprocessed"]], "evi.tif"))
idx_evi <- names(evi)[substring(names(evi), 1, 4) %in% conf$start_year:conf$end_year]
evi <- subset(evi, idx_evi)

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
  time(final_raster) <- as.Date(paste0(names(y_group), "-01-01"))
  final_raster
}

ndvi_agg <- agg_rast_yearly(ndvi)
evi_agg <- agg_rast_yearly(evi)

writeRaster(ndvi_agg, path(destination, "ndvi_agg.tif"), overwrite = TRUE)
writeRaster(evi_agg, path(destination, "evi_agg.tif"), overwrite = TRUE)