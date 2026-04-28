library(terra)
library(fs)
library(here)
library(sf)
#-------------------------------------------------------------------------------
source("R/utils/geo_comp.R")
source("R/utils/load_data.R")
#-------------------------------------------------------------------------------
read_tif_from_zips <- function(full_path_zips,tif_names = NULL) {
  if (is.null(tif_names)) {
    tif_names <- sub(".zip", ".tif", basename(full_path_zips))
  } else {
    checkmate::assert(length(tif_names) == length(full_path_zips))
  }
  paste0("/vsizip/", full_path_zips, "/", tif_names) |>
    rast()
}

parse_rast_names <- function(names_rast) {
  matches <- regmatches(names_rast, regexpr("\\d{6}", names_rast))
  matches |>
    paste0("01") |>
    as.Date(format = "%Y%m%d") |>
    format("%Y %B")
}

crop_prism <- function(prism_folder, destination_dir) {
  prism_var_folders <- dir_ls(prism_folder, type = "directory")
  ca <- get_ca()
  ca <- vect(st_union(ca))
  for (variable_folder in prism_var_folders) {
    year_folders <- dir_ls(variable_folder, type = "directory")
    destination_variable <- path(destination_dir, basename(variable_folder))
    dir_create(destination_variable, recurse = TRUE)
    for (year_folder in year_folders) {
      zip_files <- dir_ls(year_folder, regex = "\\d{6}.zip$", recurse = TRUE) |>
        sort()
      raster_year <- read_tif_from_zips(zip_files)
      ca <- project(ca, crs(raster_year))
      raster_year_ca <- mask(crop(raster_year, ca), ca)
      filename <- path(destination_variable,
                       paste0(basename(year_folder), ".tif"))
      writeRaster(raster_year_ca, filename, overwrite = TRUE)
    }
  }
}

aggregate_prism <- function(prism_folder, destination_dir) {
  prism_var_folders <- dir_ls(prism_folder, type = "directory")
  for (variable_folder in prism_var_folders) {
    year_tifs <- dir_ls(variable_folder, regexp=".tif$")
    raster_all <- rast(year_tifs)
    new_names <- parse_rast_names(names(raster_all))
    if (!length(new_names) == length(names(raster_all)) & !any(is.na(new_names))) {
      names(raster_all) <- new_names
    }
    writeRaster(raster_all,
                path(destination_dir, paste0(basename(variable_folder), ".tif")),
                overwrite=TRUE)
  }
}
#-------------------------------------------------------------------------------
raw_data <- path(here(), "data", "raw", "prism")
cropped_prism <- path(here(), "data", "preprocessed", "prism_ca")
agg_prism <- dirname(cropped_prism)

#crop_prism(raw_data, cropped_prism)
aggregate_prism(cropped_prism, agg_prism)