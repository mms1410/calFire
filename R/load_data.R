library(fs)
library(here)
library(yaml)
library(checkmate)
library(sf)
#-------------------------------------------------------------------------------
root <- here()
conf <- yaml::read_yaml(path(root, "conf", "data_processing.yaml"))
dir_prep <- path(root, conf[["path_data_preprocessed"]])
#-------------------------------------------------------------------------------
checkmate::assertFileExists(path(dir_prep, "fires.gpkg"))
fires <- read_sf(path(dir_prep, "fires.gpkg"))

checkmate::assertFileExists((path(dir_prep, "debrisflows.gpkg")))
debris <- read_sf(path(dir_prep, "debrisflows.gpkg"))

checkmate::assertFileExists(path(dir_prep, "flashfloods.gpkg"))
floods <- read_sf(path(dir_prep, "flashfloods.gpkg"))

checkmate::assertFileExists(path(dir_prep, "burnt_area.gpkg"))
burnt_area <- read_sf(path(dir_prep, "burnt_area.gpkg"))

ca_eco_13_folder <- path(root, "assets", "ca_eco_l3")
ca_eco_shape <- path(ca_eco_13_folder, "ca_eco_l3.shp")
checkmate::assertDirectoryExists(ca_eco_13_folder)
checkmate::assertFileExists(ca_eco_shape)

ca_eco_l3 <- st_read(ca_eco_shape)
ca_eco_l3 <- st_transform(ca_eco_l3, conf[["crs"]])
names(ca_eco_l3)[names(ca_eco_l3) == "NA_L3NAME"] <- "name"
ca_eco_l3 <- ca_eco_l3[, c("geometry", "name")]
#-------------------------------------------------------------------------------
rm(list = c("conf", "dir_prep", "root", "ca_eco_13_folder", "ca_eco_shape"))
