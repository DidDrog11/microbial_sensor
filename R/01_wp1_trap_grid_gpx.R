# 01_wp1_trap_grid_gpx.R -------------------------------------------------------
#
# Parse Garmin GPX exports of the Pallasjärvi (WP1) trap-grid corners into tidy
# tables: corners, quadrat centroids, and the pairwise distances between them.
#
# Input   data-raw/wp1_finland/sampling/*.gpx   (read-only)
# Output  data/field_sites/wp1_trap_grid.gpkg          (corners + quadrats, with geometry)
#         data/field_sites/wp1_trap_grid_corners.csv
#         data/field_sites/wp1_trap_grid_quadrats.csv   (centroids)
#         data/field_sites/wp1_trap_grid_pairwise_distances.csv
#         output/figures/wp1_trap_grid_distance_distribution.png
#
# `source` records the GPX file a waypoint came from, so files covering
# different parts of the design (e.g. forest vs peatland) stay distinguishable
# after they are stacked.
#
# Waypoint names are carried verbatim in `waypoint_name`. Non-standard names
# ("31B1", "42C1") and case inconsistencies ("40c") are flagged in
# `corner_nonstandard` and `corner_case_differs`, never silently corrected.
#
# These are quadrat *corners*, not trap stations. Under the Myllymäki small-
# quadrat design the corners are where the traps sit, but that is unconfirmed —
# see docs/protocols/pallasjarvi-fieldwork-protocol.qmd.

library(terra)
library(tidyterra)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(ggplot2)
library(here)

gpx_dir <- here("data-raw", "wp1_finland", "sampling")
out_dir <- here("data", "field_sites")
fig_dir <- here("output", "figures")

# read -------------------------------------------------------------------------

#' Read the waypoint layer of one GPX file, tagged with its filename
read_gpx_waypoints <- function(path) {
  vect(path, layer = "waypoints") %>%
    transmute(
      source        = tools::file_path_sans_ext(basename(path)),
      waypoint_name = name,
      elevation_m   = ele,
      recorded_at   = time,
      symbol        = sym,
      waypoint_type = type
    )
}

#' Split "31A" into quadrat 31 and corner A, flagging anything irregular
parse_waypoint_names <- function(waypoints) {
  waypoints %>%
    mutate(
      quadrat             = suppressWarnings(as.integer(str_extract(waypoint_name, "^\\d+"))),
      corner_raw          = str_remove(waypoint_name, "^\\d+"),
      corner              = str_to_upper(corner_raw),
      corner_case_differs = corner_raw != corner,
      corner_nonstandard  = !corner %in% c("A", "B", "C", "D")
    )
}

# centroids and distances ------------------------------------------------------

#' One row per quadrat: centroid geometry, extent, and which corners are present
summarise_quadrats <- function(corners) {
  quadrats <- corners %>%
    group_by(source, quadrat) %>%
    summarise(
      n_corners       = n(),
      corners_present = paste(sort(corner), collapse = ","),
      corners_abcd    = setequal(corner, c("A", "B", "C", "D")),
      n_flagged       = sum(corner_nonstandard | corner_case_differs),
      elevation_m     = mean(elevation_m, na.rm = TRUE),
      recorded_at     = min(recorded_at, na.rm = TRUE)
    ) %>%
    centroids() %>%
    arrange(source, quadrat)

  # widest separation of any two corners, per quadrat
  by_quadrat <- split(seq_len(nrow(corners)),
                      paste(corners$source, corners$quadrat, sep = "|"))
  spans <- tibble(
    quadrat_key = names(by_quadrat),
    max_span_m  = map_dbl(by_quadrat, ~ max(as.numeric(distance(corners[.x, ]))))
  )

  quadrats %>%
    mutate(quadrat_key = paste(source, quadrat, sep = "|")) %>%
    left_join(spans, by = "quadrat_key") %>%
    select(-quadrat_key)
}

#' Every unique pair of quadrat centroids, long format
quadrat_pairs <- function(quadrats) {
  d <- as.matrix(distance(quadrats))
  idx <- which(upper.tri(d), arr.ind = TRUE)

  meta <- as_tibble(quadrats) %>%
    transmute(index = row_number(), source, quadrat)

  tibble(index_i = idx[, "row"], index_j = idx[, "col"], distance_m = d[idx]) %>%
    left_join(meta, by = c("index_i" = "index")) %>%
    rename(source_i = source, quadrat_i = quadrat) %>%
    left_join(meta, by = c("index_j" = "index")) %>%
    rename(source_j = source, quadrat_j = quadrat) %>%
    transmute(source_i, quadrat_i, source_j, quadrat_j,
              distance_m, same_source = source_i == source_j) %>%
    arrange(distance_m)
}

#' Distance from each quadrat to its closest neighbour, derived from the pairs
nearest_neighbour <- function(pairs) {
  bind_rows(
    transmute(pairs, source = source_i, quadrat = quadrat_i, distance_m),
    transmute(pairs, source = source_j, quadrat = quadrat_j, distance_m)
  ) %>%
    group_by(source, quadrat) %>%
    summarise(nearest_quadrat_m = min(distance_m), .groups = "drop")
}

#' Flatten to a plain table for CSV: coordinates as lon/lat, timestamps as UTC
#'
#' terra >= 1.8 returns datetime fields as POSIXct; 1.7 returns them as strings
#' like "2025/09/04 10:54:46+00". Normalising here keeps the CSVs identical
#' whichever version is installed.
as_flat_table <- function(x) {
  as_tibble(x, geom = "XY") %>%
    rename(lon = x, lat = y) %>%
    mutate(recorded_at = as.POSIXct(recorded_at, format = "%Y/%m/%d %H:%M:%S", tz = "UTC"))
}

# plot -------------------------------------------------------------------------

#' Distribution of pairwise centroid distances
#'
#' One panel while all quadrats sit within one site. If later GPX files add
#' distant sites, the cross-site pairs will make this bimodal — facet on
#' `same_source` at that point rather than stretching one axis over both scales.
plot_distance_distribution <- function(pairs, binwidth = 20, rule_m = 50) {
  n_quadrats <- length(unique(c(pairs$quadrat_i, pairs$quadrat_j)))

  ggplot(pairs, aes(x = distance_m)) +
    geom_histogram(binwidth = binwidth, boundary = 0,
                   fill = "#4C6E8A", colour = "white", linewidth = 0.4) +
    geom_vline(xintercept = rule_m, linetype = "dashed",
               colour = "#A8503C", linewidth = 0.5) +
    annotate("text", x = rule_m, y = Inf, hjust = -0.05, vjust = 1.8,
             label = paste0(rule_m, " m — minimum spacing within a group"),
             size = 3.1, colour = "#A8503C") +
    scale_x_continuous(breaks = scales::breaks_width(50),
                       expand = expansion(mult = c(0.01, 0.03))) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
    labs(
      title    = "Separation between trap quadrats, Pallasjärvi",
      subtitle = sprintf("%d pairs from %d quadrats, %d m bins",
                         nrow(pairs), n_quadrats, binwidth),
      x        = "Distance between quadrat centroids (m)",
      y        = "Pairs",
      caption  = "Garmin GPX waypoints, recorded 2025-09-04"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(linewidth = 0.3, colour = "grey88"),
      plot.title         = element_text(face = "bold", size = 12),
      plot.subtitle      = element_text(colour = "grey35", size = 9.5),
      plot.caption       = element_text(colour = "grey45", size = 8, hjust = 0),
      axis.title         = element_text(colour = "grey30", size = 9.5),
      plot.margin        = margin(12, 16, 10, 12)
    )
}

# run --------------------------------------------------------------------------

gpx_files <- list.files(gpx_dir, pattern = "\\.gpx$", full.names = TRUE)

if (length(gpx_files) == 0) {
  stop("no GPX files found in ", gpx_dir)
}

corners <- gpx_files %>%
  map(read_gpx_waypoints) %>%
  reduce(rbind) %>%
  parse_waypoint_names() %>%
  arrange(source, quadrat, corner)

quadrats <- summarise_quadrats(corners)
pairs    <- quadrat_pairs(quadrats)
quadrats <- left_join(quadrats, nearest_neighbour(pairs), by = c("source", "quadrat"))

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

gpkg <- file.path(out_dir, "wp1_trap_grid.gpkg")
writeVector(corners, gpkg, layer = "corners", filetype = "GPKG", overwrite = TRUE)
writeVector(quadrats, gpkg, layer = "quadrats", filetype = "GPKG", insert = TRUE)

write_csv(as_flat_table(corners), file.path(out_dir, "wp1_trap_grid_corners.csv"))
write_csv(as_flat_table(quadrats), file.path(out_dir, "wp1_trap_grid_quadrats.csv"))
write_csv(pairs, file.path(out_dir, "wp1_trap_grid_pairwise_distances.csv"))

ggsave(file.path(fig_dir, "wp1_trap_grid_distance_distribution.png"),
       plot_distance_distribution(pairs),
       width = 7, height = 4.2, dpi = 300, bg = "white")

# report -----------------------------------------------------------------------

message(sprintf("%d waypoints from %d file(s): %s",
                nrow(corners), length(gpx_files),
                paste(unique(corners$source), collapse = ", ")))
message(sprintf("%d quadrats, %d with a complete A/B/C/D set",
                nrow(quadrats), sum(quadrats$corners_abcd)))
message(sprintf("quadrat span %.1f-%.1f m; nearest-neighbour centroid %.1f-%.1f m",
                min(quadrats$max_span_m), max(quadrats$max_span_m),
                min(quadrats$nearest_quadrat_m), max(quadrats$nearest_quadrat_m)))
message(sprintf("%d centroid pairs, %.1f-%.1f m (median %.1f m); %d closer than 50 m",
                nrow(pairs), min(pairs$distance_m), max(pairs$distance_m),
                median(pairs$distance_m), sum(pairs$distance_m < 50)))

flagged <- filter(corners, corner_nonstandard | corner_case_differs)
if (nrow(flagged) > 0) {
  message(sprintf("%d flagged waypoint name(s), left uncorrected: %s",
                  nrow(flagged), paste(flagged$waypoint_name, collapse = ", ")))
}

incomplete <- filter(quadrats, !corners_abcd)
if (nrow(incomplete) > 0) {
  message("quadrats without a clean A/B/C/D set:")
  message(paste(sprintf("  %s %s: %s", incomplete$source, incomplete$quadrat,
                        incomplete$corners_present), collapse = "\n"))
}
