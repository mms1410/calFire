library(terra)
library(here)
library(fs)
#-------------------------------------------------------------------------------
prism <- rast(path(here(), "data", "preprocessed", "prism.tif"))
destination_dir <- path(here(), "data", "intermediate")
source(path(here(), "R", "utils", "geo_comp.R"))
#-------------------------------------------------------------------------------
prism_df <- rast_to_series(prism)
write.csv(prism_df, file = path(destination_dir, "ts_prism.csv"))
