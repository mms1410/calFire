library(terra)
library(sf)
library(checkmate)
library(fs)
#-------------------------------------------------------------------------------

subset_raster_factory <- function(vect) {
  #checkmate::assert(!is.na(crs(user_crs, describe = TRUE)))
  function(raster) {
    mask(crop(raster, vect), vect)
  }
}

agg_tifs <- function(source_dir, destination_dir) {
  prism_variables <- dir_ls(source_dir, type = "directory")
  for (prism_variable in prism_variables) {
    destination <- path(destination_dir, basename(prism_variable))
    years_path <- dir_ls(prism_variable, regexp = ".tif$")
    years_path <- sort(years_path)
    rast_all <- rast(years_path)
    names_new <- parse_rast_names(names(rast_all))
    names(rast_all) <- names_new
    writeRaster(rast_all,
               filename = path(destination_dir,
                               paste0(basename(prism_variable), ".tif"))
               )
 }
}
#'
#'
#'
agg_nlyr_rast <- function(nlyrrast, groups, agg_func = mean) {
  # yearly: '_.*', monthly: '.*_'
  groups <- groups[order(as.numeric(names(groups)))]
  out <- tapp(nlyrrast, groups, fun = agg_func)
  names(out) <- names(groups)
  out
}

#'
#'
#'
query_raster_points <- function(raster, point_frame) {
  
  checkmate::assert(crs(raster) == crs(point_frame))
  terra::extract(raster, vect(point_frame))
  
}


#'
#'
#'
rast_to_series <- function(nlyr_raster) {
  total <- list()
  qq <- c(0, 0.25, 0.5, 0.75, 1)
  for (name in names(nlyr_raster)) {
    
    date_split <- strsplit(name, "_")[[1]] # naming convention 'YYYY_M'
    yyyy <- as.integer(date_split)[1]  # year
    m <- as.integer(date_split)[2]  # month
    
    raster <- nlyr_raster[[name]]
    quantiles <- terra::global(raster,
                          fun = quantile,
                          probs = qq,
                          na.rm = TRUE)
    names(quantiles) <- c("q0", "q0.25", "q0.5", "q0.75", "q1")
    mean_sd <- terra::global(raster,
                             fun = c("mean", "sd"),
                             na.rm = TRUE)
    data <- cbind(year = yyyy, month = m, quantiles, mean_sd)
    rownames(data) <- NULL
    total <- rbind(total, data)
  }
  total
}

get_centroid_boundary_distance <- function(geom_data){
  centers <- st_centroid(geom_data)
  distances <- st_distance(centers$geom, geom_data$geom)
  assert(length(as.numeric(distance)) == nrow(geom_data))
  d <- as.numeric(distances)
}