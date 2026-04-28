library(rgee)

rgee::ee_Initialize()
rgee::ee_check() # requires python and earthengin-api
ca_bbox <- c(-124.5, 32.5, -114, 42)
#-------------------------------------------------------------------------------
library(earthdatalogin)
earthdatalogin::edl_search("ASTER Global Digital Elevation Model V003")
earthdatalogin::edl_stac_urls()
#-------------------------------------------------------------------------------
library(rstac)
ca_bbox <- c(-124.5, 32.5, -114, 42)
s1 <- "https://planetarycomputer.microsoft.com/dataset/nasadem"
s2 <- "https://planetarycomputer.microsoft.com/api/stac/v1"
top_level_endpoint <- rstac::stac(s2)
rstac::get_request(top_level_endpoints)
collection_query <- catalog |> rstac::collections()
query_request <- get_request(collection_query)
rstac::stac_search(q = collection_query)
collections(collection_query, collection_id = "NASADEM_SC")
