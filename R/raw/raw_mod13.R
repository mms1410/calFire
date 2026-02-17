library(yaml)
library(fs)
library(here)
library(sf)
library(dotenv)
library(checkmate)
library(appeears)
#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "data_processing.yaml"))
destination_dir <- path(here(), conf[["path_data_raw"]])

checkmate::assert("mod13" %in% names(conf))
query_frame <- do.call(
  rbind, lapply(conf$mod13, as.data.frame)
)
checkmate::assert(all(c("subtask", "product", "layer") %in% names(query_frame)))
query_frame$task <- "mod13"
query_frame$start <- paste0(conf[["start_year"]], "-01-01")
query_frame$end <- paste0(conf[["end_year"]], "-12-31")
#-------------------------------------------------------------------------------
dotenv::load_dot_env()
checkmate::assert("EARTHDATA_PASSWORD" %in% names(Sys.getenv()))
checkmate::assert("EARTHDATA_USER" %in% names(Sys.getenv()))
#checkmate::assert("EARTHDATA_TOKEN" %in% names(Sys.getenv()))

available_layers <- rs_layers(product = "MOD13A3.061") 
checkmate::assert_subset(query_frame$band, available_layers$Band)
#-------------------------------------------------------------------------------
#options(keyring_backend = "file")
#rs_set_key(
#  user = Sys.getenv()[["EARTHDATA_USER"]],
#  password = Sys.getenv()[["EARTHDATA_PASSWORD"]])
checkmate::assertFileExists("assets/ca_state/CA_State.shp")
ca_shape <- (st_read("assets/ca_state/CA_State.shp"))
ca_shape <-  st_transform(ca_shape, crs = conf[["crs"]])
if (nrow(ca_shape) > 1) {
  ca_shape <- st_union(ca_shape)
  ca_shape <- st_as_sf(ca_shape)
}

task <- rs_build_task(
  df = query_frame,
  roi = ca_shape,
  format = "geotiff"
)

req <- rs_request(
  request = task,
  user = Sys.getenv()[["EARTHDATA_USER"]],
  transfer = TRUE,  # Download automatically when ready
  path = destination_dir,
  verbose = TRUE
)
#-------------------------------------------------------------------------------
  rm(list = ls())