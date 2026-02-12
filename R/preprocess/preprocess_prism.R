library(yaml)
library(fs)
library(here)
library(checkmate)
library(terra)
#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "config.yaml"))
years <- conf$start_year:conf$end_year
#-------------------------------------------------------------------------------
source_folder <- path(here(), conf$path_data_raw, "prism")

msg <-paste0("Expected to find folder ", source_folder)
checkmate::assert(dir_exists(prism_folder), msg)

prism_files <- dir_ls(source_folder)
prism_files_grouped <- split(prism_files,
                             substr(prism_files, nchar(prism_files) - 9,nchar(prism_files) - 6))

for (year in years) {
  file_count <- length(prism_files_grouped[[as.character(year)]])
  msg <- paste0("Expected to get 12 (each month) prism files for year ", year, "but got ", file_count)
  checkmate::assert(file_count == 12, msg)
}
#-------------------------------------------------------------------------------
#*.bil   ← raster values (precipitation, NDVI, etc.)
#*.hdr   ← raster metadata (rows, cols, datatype)
#*.prj   ← projection

for (year in years) {
  prism_group <- prism_files_grouped[[as.character(year)]]
  for (file_month in prism_group) {
    data_month <- 
  }
}