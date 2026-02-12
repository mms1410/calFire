# https://docs.ropensci.org/MODIStsp/
# MOD13Q1
library(yaml)
library(fs)
library(here)
library(sf)
library(MODIStsp)
library(dotenv)
library(checkmate)
#-------------------------------------------------------------------------------
conf <- read_yaml(path(here(), "conf", "config.yaml"))
start_date <- paste0(conf$start_year, ".01.01")
end_date <- paste0(conf$end_year, ".31.12")
bbox_ca <- conf$bbox_ca
modis_prodname <- conf$modis_prodname
modis_selprod <- conf$modis_selprod
modis_bandnames <- conf$modis_bandnames
#-------------------------------------------------------------------------------
dotenv::load_dot_env()
checkmate::assert("EARTHDATA_PASSWORD" %in% names(Sys.getenv()))
checkmate::assert("EARTHDATA_USER" %in% names(Sys.getenv()))
checkmate::assert(modis_selprod %in% MODIStsp_get_prodnames())
for (bandname in modis_bandnames) {
  assert(bandname %in% MODIStsp_get_prodlayers(modis_prodname)$bandnames)
}
# information on available data
MODIStsp_get_prodlayers(modis_prodname)
#-------------------------------------------------------------------------------
MODIStsp(
  gui = FALSE,
  out_folder = path(conf["path_data_raw"], "mod13"),
  user = Sys.getenv("EARTHDATA_USER"),
  password = Sys.getenv("EARTHDATA_PASSWORD"),
  start_date = start_date,
  end_date = end_date,
  bbox = bbox_ca,
  selprod = "Vegetation_Indexes_16Days_1Km (M*D13A2)",
  bandsel = "EVI",
  verbose = TRUE
)

MODIStsp(gui             = FALSE, 
         out_folder      = "$tempdir", 
         selprod         = "Vegetation_Indexes_16Days_1Km (M*D13A2)",
         bandsel         = c("EVI", "NDVI"), 
         quality_bandsel = "QA_usef", 
         indexes_bandsel = "SR", 
         user            = Sys.getenv("EARTHDATA_USER") ,
         password        = Sys.getenv("EARTHDATA_PASSWORD"),
         start_date      = "2020.06.01", 
         end_date        = "2020.06.15", 
         verbose         = FALSE)

MODIStsp(
  gui = FALSE,
  selprod = "Vegetation_Indexes_16Days_1Km (M*D13A2)",
  bandsel = "NDVI",
  start_date = "2000.02.18",
  end_date   = "2025.12.31",
  user            = Sys.getenv("EARTHDATA_USER") ,
  password        = Sys.getenv("EARTHDATA_PASSWORD"),
)
#-------------------------------------------------------------------------------
library(MODISTools)
mt_products()
bands <- mt_bands(product = "MOD13Q1") # 250m_16_days_NDVI, 250m_16_days_EVI


#-------------------------------------------------------------------------------
library(modisfast)
# collection = MOD13Q1.061

modisfast::mf_get_url(collection = "MOD13Q1.061")
#-------------------------------------------------------------------------------
library(appeears)
rs_set_key(user = Sys.getenv("EARTHDATA_USER"), password = Sys.getenv("EARTHDATA_PASSWORD"))


rs_products()
rs_layers("MOD13A1.061") |> View() #500m 16 days EVI, 500m 16 days NDVI
rs_set_key(user = Sys.getenv("EARTHDATA_USER"), password = Sys.getenv("EARTHDATA_PASSWORD"))
--------------------------------------------------------------------------------
  rm(list = ls())