library(rvest)
library(here)
library(fs)
library(data.table)
library(R.utils)
library(yaml)
#-------------------------------------------------------------------------------
conf_path <- read_yaml(path(here(), "conf", "paths.yaml"))
conf_data <- read_yaml(path(here(), "conf", "data.yaml"))
start_year <- conf_data$start_year
end_year <- conf_data$end_year
url <- conf_data$url_storms
destination_folder <- path(here(), conf_path$path_raw, "noaa")
#-------------------------------------------------------------------------------
years <- start_year:end_year
dir_create(destination_folder)

pattern_year_selection <- paste0("_d(", paste(years, collapse = "|"), ")_")
pattern_type_selection <- paste0("StormEvents_([^ -]+)-ftp.*")

hyperref_stems <- read_html(url) |>
  html_elements("a") |>
  html_attr("href")

selection <- hyperref_stems[grepl(pattern_year_selection, hyperref_stems)]
types <- sub(pattern_type_selection, "\\1", selection)
selection_grouped <- split(selection, types)

options(timeout = 300) # 5 min per dataset
for (type in names(selection_grouped)) {
  total <- data.table()
  for (hyperref_stem in selection_grouped[[type]]) {
    query_url <- paste0(url, hyperref_stem)
    dt <- fread(paste0(url, hyperref_stem))
    total <- rbindlist(list(total, dt))
  }
  filename <- paste0("noaa_stormevents_", type, conf_data$start_year, "-", conf_data$end_year, ".csv")
  fwrite(total, path(destination_folder, filename))
}
#-------------------------------------------------------------------------------
rm(list = ls())