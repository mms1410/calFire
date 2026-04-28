get_count_ts <- function(data, by = "month", date_col = "date") {
  data <- st_drop_geometry(data)
  
  years <- lubridate::year(data[[date_col]])
  months <- lubridate::month(data[[date_col]])
  to_group <- as.Date(paste0(years, "-", months, "-01"))
  
  data |>
    mutate(time = to_group) |>
    group_by(time) |>
    summarize(count = n())
}
read_tif_from_zip <- function(path_to_zip, filename = NULL) {
  if (is.null(filename)) {
    filename <- basename(path_to_zip)
    filename <- tools::file_path_sans_ext(filename)
    filename <- paste0(filename, ".tif")
  }
  terra::rast(path(paste0("/vsizip//", path_to_zip), filename))
}