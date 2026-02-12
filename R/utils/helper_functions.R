library(lubridate)
#-------------------------------------------------------------------------------
source("R/load_data.R")
#-------------------------------------------------------------------------------
count_by_year <- function(fires, floods, debris){
  fires <- as.data.table(fires)
  floods <- as.data.table(floods)
  debris <- as.data.table(debris)
  
  yearly_fires <- fires[, .(id, year = lubridate::year(date))][
    , .(fires = .N), by = year]
  yearly_floods <- floods[, .(id, year = lubridate::year(date))][
    , .(floods = .N), by = year]
  yearly_debris <- debris[, .(id, year = lubridate::year(date))][
    , .(debris = .N), by = year]
  
  yearly_fires[yearly_floods, on = "year"][yearly_debris, on = "year"]
}
