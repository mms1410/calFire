library(ggplot2)
library(USAboundaries)
library(lubridate)
library(gifski)
library(sf)
library(yaml)
library(fs)
#-------------------------------------------------------------------------------
library(ggsci)

# hc_20 <- c(
#   "#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F",
#   "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85",
#   "#E6A817", "#A93226", "#1A5276", "#117A65", "#6C3483",
#   "#D35400", "#1E8449", "#2E86C1", "#CB4335", "#839192"
# )
# aaas_20 <- colorRampPalette((ggsci::pal_aaas()(10)))(20)
# options(
#   ggplot2.discrete.colour = hc_20,
#   ggplot2.discrete.fill   = hc_20
# )
#-------------------------------------------------------------------------------
theme_set(theme_light())
theme_ecoregion <- theme(
  legend.position = "bottom",
  legend.text = element_text(size = 5),
  legend.title = element_text(size = 6),
  legend.key.size = unit(0.2, "cm")
)
options(ggplot2.continuous.colour = "viridis")
scale_fill <- function(...) scale_fill_viridis_c(...)
scale_colour <- function(...) scale_colour_viridis_c(...)
#-------------------------------------------------------------------------------


gg_save <- function(filename, destination_dir = path(here(), "assets", "plots"),
                    dpi = 300, width = 9, height = 5) {
  ggsave(path(destination_dir, paste0(filename, ".png")), 
         dpi = dpi,
         width = width,
         height = height)
}

get_fires_layer <- function(color = "red", shape = 19, size = 0.1, alpha = 0.4, ...) {
  geom_sf(data = fires,
          color = color,
          shape = shape,
          size = size,
          alpha = alpha)
}
get_ecoz_layer <- function(legend = FALSE, alpha = 0.3, fill_var = "name", ...) {
  geom_sf(data = ca_eco_l3,
          aes(fill = .data[[fill_var]]),
          alpha = alpha,
          show.legend = legend)
}
get_ca_layer <- function(alpha = 0.1, fill = "grey", ...) {
  geom_sf(data = ca, fill = fill, alpha = alpha)
}

raster_to_pngs <- function(rasters, destination_dir, raster_names = NULL) {
  
  fs::dir_create(destination_dir)
  names(rasters) <- raster_names
  
  for (rast_name in raster_names) {
    r <- rasters[[rast_name]]
    ggplot() +
      tidyterra::geom_spatraster(data = r, aes(fill = .data[[rast_name]])) +
      theme(legend.position = "none") +
      ggtitle(rast_name) +
      xlab("Longitude") +
      ylab("Latitude") +
      scale_fill_viridis_c(option = "viridis", na.value = "transparent")

    filename <- gsub("\\s", "_", rast_name)
    gg_save(filename, destination_dir = destination_dir)
  }
}
pngs_to_gif <- function(source_dir, destination_full, filenames = NULL, fps = 10) {
  dir_create(dirname(destination_full))
  pngs <- dir_ls(source_dir, glob = "*.png")
  #if(!is.null(filenames)){
  #  pngs <- pngs[match(paste0(filenames, ".png"), basename(pngs))]
  #}
  gifski(png_files = pngs, gif_file = destination_full)
}
#-------------------------------------------------------------------------------