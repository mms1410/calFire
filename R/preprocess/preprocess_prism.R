library(yaml)
library(fs)
library(here)
library(checkmate)
library(terra)
library(USAboundaries)
library(sf)
library(zoo)
#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "data_processing.yaml"))
years <- conf$start_year:conf$end_year
ca <- us_states(states = "CA")
ca <- st_transform(ca, st_crs(conf$crs))
#-------------------------------------------------------------------------------
source_folder <- path(here(), conf$path_data_raw, "prism")
destination_folder <- path(here(), conf$path_data_preprocessed)

msg <- paste0("Expected to find folder ", source_folder)
checkmate::assert(dir_exists(source_folder), msg)

prism_files <- dir_ls(source_folder)
prism_files_grouped <- split(prism_files,
                             substr(prism_files, nchar(prism_files) - 9,nchar(prism_files) - 6))

for (year in years) {
  file_count <- length(prism_files_grouped[[as.character(year)]])
  msg <- paste0("Expected to get 12 (each month) prism files for year ", year, "but got ", file_count)
  checkmate::assert(file_count == 12, msg)
}
#-------------------------------------------------------------------------------
process_raster_img <- function(zip_path) {
  content <- unzip(zip_path, list = TRUE)$Name
  #*.bil   ← raster values
  bil_file <- content[grepl("\\.bil$", content)]
  vsi_path <- paste0("/vsizip/", zip_path)
  ppt_raster <- rast(paste0("/vsizip/", zip_path, "/", bil_file))
  ppt_raster <- project(ppt_raster, crs(ca))
  ppt_raster_ca <- crop(ppt_raster, ca)
  #mask(ppt_raster_ca, ca_vect)
}

destination <- path(destination_folder, year)
raster_list <- list()
for (year in years) {
  prism_group <- prism_files_grouped[[as.character(year)]]
  ym <- as.yearmon(paste0(year, "-01")) + 0:11/12
  
  yearly_prism <- rast(lapply(prism_group, process_raster_img))
  
  terra::time(yearly_prism) <- as.Date(ym)
  raster_list[[as.character(year)]] <- yearly_prism
}
prism_final <- rast(raster_list)

dir_create(destination_folder)
writeRaster(prism_final,
            path(destination_folder, "prism.tif"),
            overwrite = TRUE)

# TODO: common scale each raster
#-------------------------------------------------------------------------------
rm(list = ls())