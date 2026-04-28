library(fs)
library(rvest)
library(httr2)
library(here)
#-------------------------------------------------------------------------------
# https://data.prism.oregonstate.edu/PRISM_datasets.pdf
options(timeout = 300)
url_prism <- "https://data.prism.oregonstate.edu/time_series/us/lt/800m/"
years <- 2025:2025

log_message_fail <- function(msg, log_fails_file) {
  timestamped <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", msg)
  message(timestamped)
  cat(timestamped, "\n", file = log_fails_file, append = TRUE)
}

download_with_retry <- function(url, destfile, retries = 3) {
  for (i in seq_len(retries)) {
    tryCatch({
      download.file(url, destfile, mode = "wb", quiet = TRUE)
      return(invisible(TRUE))
    }, error = function(e) {
      # wait before retrying
      Sys.sleep(5)
    })
  }
  # do not throw error but return FALSE and give warning
  warning("Failed after ", retries, " attempts: ", url)
  return(invisible(FALSE))
}


prism_page <- read_html(url_prism)
folders <- prism_page |>
  html_elements("a") |>
  html_attr("href")
subfolders <- folders[grepl("^[^/]+/$", folders)]

for (subfolder in subfolders) {
  if (subfolder == "ppt/") {
    next
  }
  query_url <- paste0(url_prism, subfolder, "monthly")
  query_page <- read_html(query_url)
  folders <- query_page |>
    html_elements("a") |>
    html_attr("href")
  for (year in years) {
    destination_dir <- path(here(), "data", "raw", "prism", subfolder)
    dir_create(destination_dir)
    query_folder_url <- paste0(query_url, "/", year)
    subquery_page <- read_html(query_folder_url)
    subquery_items <- subquery_page |>
      html_elements("a") |>
      html_attr("href")
    zips <- subquery_items[grepl(".zip$", subquery_items)]
    final_destination <- path(destination_dir, year)
    dir_create(final_destination)
    for (zipfile in zips) {
      download_url <- paste0(query_folder_url, "/", zipfile)  # path uses https:/.. instead of https://...
      download_with_retry(download_url, path(final_destination, zipfile))
      #download.file(path(query_folder_url, zipfile),
      #              path(final_destination, zipfile))
    }
  }
}