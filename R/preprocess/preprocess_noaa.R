library(here)
library(fs)
library(data.table)
library(checkmate)
library(yaml)
library(sf)
#-------------------------------------------------------------------------------
conf_data <- yaml::read_yaml(path(here(), "conf", "data.yaml"))
conf_path <- yaml::read_yaml(path(here(), "conf", "paths.yaml"))
crs_destination <- conf_data[["crs"]]
#crs_source <- 4326
source_folder <- path(here(), conf_path$path_data_raw, "noaa")
dir_preprocessed <- path(here(), conf_path$path_data_preprocessed)

filename_details_raw <- paste0("noaa_stormevents_", conf_data$start_year, "-", conf_data$end_year, ".csv")

checkmate::assert(is_dir(source_folder), msg)
checkmate::assert(fs::is_file(raw_file))
#-------------------------------------------------------------------------------
# filter relevant_columns
stormevents <- fread(raw_file)
stormevents <- stormevents[STATE == "CALIFORNIA"]

to_date <- function(x) as.POSIXct(x, "%d-%b-%y %H:%M:%S", tz = "UTC")
stormevents[, `:=`(date = to_date(BEGIN_DATE_TIME),
                duration = as.numeric(difftime(to_date(END_DATE_TIME), to_date(BEGIN_DATE_TIME), units = "mins")))]
setnames(stormevents,
         old = c("EVENT_TYPE", "EVENT_ID", "BEGIN_LAT", "BEGIN_LON", "FLOOD_CAUSE"),
         new = c("type", "id", "lat", "lon", "cause"))

dir_create(dir_preprocessed)

floods <- stormevents[type == "Flash Flood" & !is.na(lat) & !is.na(lon), c("id", "date", "cause", "lat", "lon")] |>
  st_as_sf(coords = c("lon", "lat"), crs = crs_source, sf_column_name = "flash_flood")

floods <- st_transform(floods, crs = crs_destination)
st_write(floods, path(dir_preprocessed, "flashfloods.gpkg"), append = FALSE)

debris <- stormevents[type == "Debris Flow" & !is.na(lat) & !is.na(lon), c("id", "date", "cause", "lat", "lon")] |>
  st_as_sf(coords = c("lon", "lat"), crs = crs_source, sf_column_name = "debris_flow")
debris <- st_transform(debris, crs = crs_destination)
st_write(debris, path(dir_preprocessed, "debrisflows.gpkg"), append = FALSE)
#-------------------------------------------------------------------------------
rm(list = ls())