# https://droughtmonitor.unl.edu/DmData/GISData.aspx
library(terra)
library(sf)
data <- st_read("https://droughtmonitor.unl.edu/data/json/usdm_20260106.json")
unique(st_geometry_type(data))
ca <- get_ca()
data <- st_transform(data, st_crs(ca))
data2 <- st_intersection(data, ca)

#data <- terra::rast(file.choose())
ca <- get_ca()
#ca_vec <- terra::vect(ca)
#ca_vec <- project(ca_vec, crs(data))
#crop(data, ca_vec)

#https://gis.data.ca.gov/datasets/d8bfc5ad7ede4e1ca60b0666efc2b50d_0/explore?location=37.262851%2C-119.175502%2C6
#https://droughtmonitor.unl.edu/DmData/DataTables.aspx#
# https://www.drought.gov/data-maps-tools/us-gridded-palmer-drought-severity-index-pdsi-gridmet
# https://www.northwestknowledge.net/metdata/data/
data <- st_read(file.choose())
data <- rast(file.choose())
plot(data)
