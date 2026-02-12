library(here)
library(fs)
library(data.table)
library(checkmate)
library(yaml)
library(sf)
#-------------------------------------------------------------------------------
conf <- yaml::read_yaml(path(here(), "conf", "data_processing.yaml"))
crs <- conf[["crs"]]
source_folder <- path(here(), conf$path_data_raw, "noaa")
dir_preprocessed <- path(here(), conf$path_data_preprocessed)

# noaa raw data contains of 3 files: details, fatalities, locations
details_name <- paste0("noaa-stormevents_", conf$start_year, "-", conf$end_year, "_details.csv")
locations_name <- paste0("noaa-stormevents_", conf$start_year, "-", conf$end_year, "_locations.csv")
details_path <- path(source_folder, details_name)
locations_path <- path(source_folder, locations_name)

msg <- paste0("It appears there is no folder of raw data or path is wrong. \n",
              "Expected folder: ", source_folder)
checkmate::assert(is_dir(source_folder), msg)

msg <- paste0("Expected to find file '", details_name , "'in ", source_folder)
checkmate::assert(is_file(details_path), msg)

msg <- paste0("Expected to find file '", locations_name , "'in ", source_folder)
checkmate::assert(is_file(locations_path), msg)
#-------------------------------------------------------------------------------
# filter relevant_columns
details <- fread(details_path)
details <- details[STATE == "CALIFORNIA"]

to_date <- function(x) as.POSIXct(x, "%d-%b-%y %H:%M:%S", tz = "UTC")
details[, `:=`(date = to_date(BEGIN_DATE_TIME),
                duration = as.numeric(difftime(to_date(END_DATE_TIME), to_date(BEGIN_DATE_TIME), units = "mins")))]
setnames(details,
         old = c("EVENT_TYPE", "EVENT_ID", "BEGIN_LAT", "BEGIN_LON", "FLOOD_CAUSE"),
         new = c("type", "id", "lat", "lon", "cause"))

dir_create(dir_preprocessed)

details[type == "Flash Flood" & !is.na(lat) & !is.na(lon), c("id", "date", "cause", "lat", "lon")] |>
  st_as_sf(coords = c("lon", "lat"), crs = crs, sf_column_name = "flash_flood") |>
  st_write(path(dir_preprocessed, "flashfloods.gpkg"), append = FALSE)

details[type == "Debris Flow" & !is.na(lat) & !is.na(lon), c("id", "date","cause", "lat", "lon")] |>
  st_as_sf(coords = c("lon", "lat"), crs = crs, sf_column_name = "debrisflow") |>
  st_write(path(dir_preprocessed, "debrisflows.gpkg"), append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())