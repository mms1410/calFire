library(rvest)
library(fs)
library(yaml)
library(here)
library(raster)

#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "data_processing.yaml"))
years <- conf$start_year:conf$end_year
destination_folder <- path(here(), conf$path_data_raw, "prism")
url <- "https://ftp.prism.oregonstate.edu/prior_versions/ppt/monthly_M2_201506/"
url <- conf$url_prism
#-------------------------------------------------------------------------------
dir_create(destination_folder)

prism_variable <- "ppt"
prism_region <- "us"
prism_resolution <- "800m"
prism_format <- "?format=bil"
months <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
for (year in years) {
  for (month in months) {
    prism_timeperiod <- paste0(year, month)
    url_prism <- paste0(
      url,
      path(prism_region, prism_resolution, prism_variable, prism_timeperiod),
      prism_format
      )
    filename <- paste0(c("prism", prism_variable, prism_region, prism_resolution, prism_timeperiod), collapse = "_")
    destination_file <- path(destination_folder, paste0(filename, ".zip"))
    download.file(url_prism, destination_file, mode = "wb")
  }
}
#-------------------------------------------------------------------------------
rm(list = ls())