# 03_wp1_soil_point_coords.R ---------------------------------------------------
#
# Load the hand-entered GPS waypoints for the WP1 soil points (quadrat corners
# and pitfall-line points), apply documented corrections, impute the missing
# corner of any quadrat that has three, and derive quadrat centroids, geometry
# and nearest-neighbour spacing.
#
# Input   data-raw/wp1_finland/wp1_corner_coords.csv   (read-only, as entered)
# Output  data/field_sites/wp1_soil_points.csv         one row per point
#         data/field_sites/wp1_quadrats.csv            one row per quadrat
#         data/field_sites/wp1_pitfall_lines.csv       one row per pitfall line
#         data/field_sites/wp1_soil_points.gpkg        points, centroids and
#                                                      quadrat polygons, EPSG:3067
#
# The raw file is never edited. Every departure from it is a row in
# `corrections` below, matched on the waypoint name AND the coordinates as
# entered, so a correction applies exactly once and becomes inert (with a
# warning) if the raw row is ever fixed at source. Exact duplicate rows
# (same name and coordinates) are collapsed generically.
#
# Corner letters are assumed to run around the quadrat perimeter, A-B-C-D, so
# A/C and B/D are the diagonals. That holds for every complete quadrat entered
# on 14 Sep 2026 and is what the parallelogram imputation relies on.

library(terra)
library(tidyterra)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(tibble)
library(here)

raw_path  <- here("data-raw", "wp1_finland", "wp1_corner_coords.csv")
out_dir   <- here("data", "field_sites")
crs_wgs84 <- "EPSG:4326"
crs_tm35  <- "EPSG:3067"   # ETRS-TM35FIN, metres

# A 15 m square measured with ~2 m error per corner. Most quadrats trip this
# flag: the residual mixes GPS error with how square the quadrat is on the
# ground, and one fix per corner cannot separate them. The flag is
# informational; `shape_rmse_m` gives the graded version.
side_ok <- c(10, 20)
diag_ok <- c(17, 26)
side_nominal <- 15
diag_nominal <- 15 * sqrt(2)

# An imputed corner this close to a recorded one means the three recorded
# points are near-collinear and do not define a square; leave the quadrat at
# three corners rather than invent a fourth.
impute_min_sep <- 8

# corrections ------------------------------------------------------------------

# `lat`/`lon` are the values AS ENTERED in the raw file; they identify the row.
corrections <- tribble(
  ~waypoint_name, ~lat,      ~lon,      ~action,  ~new_name, ~new_lat,  ~new_lon,  ~reason,
  "38A",  68.015549, 24.146634, "set",    NA,        NA,        24.145310, "longitude typed as 42D's; re-read from the GPS unit, 14 Sep 2026",
  "42B",  68.015830, 24.146983, "set",    NA,        68.015710, 24.147133, "entered as a copy of 42A; re-read from the GPS unit, 14 Sep 2026",
  "42C",  68.015731, 24.147005, "set",    NA,        68.015612, NA,        "latitude typed as 42D's; re-read from the GPS unit, 14 Sep 2026",
  "43A",  68.017810, 24.148397, "set",    NA,        68.016810, NA,        "digit slip placing the corner 130 m north; 68.0168 fits the other three",
  "43D",  68.016664, 24.148692, "drop",   NA,        NA,        NA,        "first of two 43 sets entered; superseded by the second (this D sits 2.7 m from C)",
  "43A",  68.016781, 24.148397, "drop",   NA,        NA,        NA,        "first of two 43 sets entered; superseded by the second",
  "40B",  68.016825, 24.147270, "rename", "41B",     NA,        NA,        "recorded in the 41 sequence and 40 has its own B; 13-20 m from 41 A, C, D",
  "35D",  68.015236, 24.143080, "rename", "34D",     NA,        NA,        "two sets entered as 35; this southern set is 34 (matched in the field to 68.015252, 24.143071)",
  "35C",  68.015334, 24.142698, "rename", "34C",     NA,        NA,        "as 35D -> 34D",
  "35B",  68.015433, 24.142751, "rename", "34B",     NA,        NA,        "as 35D -> 34D",
  "35A",  68.015347, 24.143162, "rename", "34A",     NA,        NA,        "as 35D -> 34D"
)

same <- function(a, b) abs(a - b) < 5e-7

apply_corrections <- function(pts, corrections) {
  pts <- pts %>% mutate(correction = NA_character_, dropped = FALSE)
  for (i in seq_len(nrow(corrections))) {
    cr  <- corrections[i, ]
    hit <- pts$waypoint_name == cr$waypoint_name & same(pts$lat, cr$lat) & same(pts$lon, cr$lon)
    if (sum(hit) != 1) {
      warning(sprintf("correction %d (%s %s) matched %d rows, expected 1; the raw file may have changed",
                      i, cr$action, cr$waypoint_name, sum(hit)), call. = FALSE)
      next
    }
    pts$correction[hit] <- paste0(cr$action, ": ", cr$reason)
    if (cr$action == "drop")   pts$dropped[hit] <- TRUE
    if (cr$action == "rename") pts$waypoint_name[hit] <- cr$new_name
    if (cr$action == "set") {
      if (!is.na(cr$new_lat)) pts$lat[hit] <- cr$new_lat
      if (!is.na(cr$new_lon)) pts$lon[hit] <- cr$new_lon
    }
  }
  pts
}

# read and normalise -----------------------------------------------------------

raw <- read_csv(
  raw_path,
  col_types = cols(.default = col_character(), lat = col_double(), lon = col_double(),
                   collection_date = col_date())
)

pts <- raw %>%
  mutate(
    raw_row       = row_number(),
    waypoint_raw  = waypoint_name,
    # "[duplicate ID]" is a note the GPS export appended, not part of the name;
    # "MSextra" is the second pitfall line, MS+ in the protocol
    waypoint_name = waypoint_name %>%
      str_remove("\\s*\\[duplicate ID\\]$") %>%
      str_replace("^MSextra", "MS+") %>%
      str_trim()
  ) %>%
  select(raw_row, waypoint_raw, waypoint_name, lat, lon, collection_date, notes) %>%
  apply_corrections(corrections)

n_dropped <- sum(pts$dropped)
pts <- pts %>% filter(!dropped) %>% select(-dropped)

n_before <- nrow(pts)
pts <- pts %>% distinct(waypoint_name, lat, lon, .keep_all = TRUE)
n_exact_dups <- n_before - nrow(pts)

dup_names <- pts %>% count(waypoint_name) %>% filter(n > 1)
if (nrow(dup_names)) {
  stop("waypoint names still duplicated after corrections: ",
       paste(dup_names$waypoint_name, collapse = ", "))
}

# parse ------------------------------------------------------------------------

pts <- pts %>%
  mutate(
    # Quadrat corners are "<number><letter>". Reference soils are "REF<n>".
    # Anything else that ends in a point number or a single point letter is a
    # non-quadrat trap line: "MS1", "MS+2", "LOM-A", "8-10A". The line name is
    # everything before the trailing point, trimmed of a space or hyphen.
    unit_type = case_when(
      str_detect(waypoint_name, "^\\d+[A-Da-d]$")                   ~ "quadrat",
      str_detect(waypoint_name, "^REF-?[FP]?\\d+$")                   ~ "reference",
      str_detect(waypoint_name, "^\\S.*?[ -]?(\\d+|[A-Za-z])$")       ~ "pitfall_line",
      TRUE                                                          ~ NA_character_
    ),
    sq_id   = if_else(unit_type == "quadrat", as.integer(str_extract(waypoint_name, "^\\d+")), NA_integer_),
    corner  = if_else(unit_type == "quadrat", str_to_upper(str_sub(waypoint_name, -1)), NA_character_),
    point   = if_else(unit_type == "pitfall_line", str_to_upper(str_extract(waypoint_name, "(\\d+|[A-Za-z])$")), NA_character_),
    line_id = if_else(unit_type == "pitfall_line",
                      str_remove(waypoint_name, "[ -]?(\\d+|[A-Za-z])$") %>% str_trim(), NA_character_),
    # a bare number ("31") is not a point name; refuse rather than invent a unit
    unit_type = if_else(unit_type == "pitfall_line" & line_id == "", NA_character_, unit_type),
    source  = "gps",
    imputed = FALSE
  )

if (any(is.na(pts$unit_type))) {
  stop("waypoint names that do not parse: ",
       paste(pts$waypoint_name[is.na(pts$unit_type)], collapse = ", "))
}

# project to metres ------------------------------------------------------------

to_xy <- function(df) {
  xy <- vect(as.data.frame(df), geom = c("lon", "lat"), crs = crs_wgs84) %>%
    project(crs_tm35) %>%
    crds()
  df %>% mutate(x = xy[, 1], y = xy[, 2])
}

to_lonlat <- function(df) {
  ll <- vect(as.data.frame(df), geom = c("x", "y"), crs = crs_tm35) %>%
    project(crs_wgs84) %>%
    crds()
  df %>% mutate(lon = ll[, 1], lat = ll[, 2])
}

pts <- to_xy(pts)

# impute the fourth corner where three were recorded ---------------------------

opposite <- c(A = "C", B = "D", C = "A", D = "B")

impute_corner <- function(q) {
  missing <- setdiff(names(opposite), q$corner)
  if (nrow(q) != 3 || length(missing) != 1) return(NULL)
  opp <- opposite[[missing]]
  nb  <- setdiff(names(opposite), c(missing, opp))
  at  <- function(cn, col) q[[col]][q$corner == cn]
  x_new <- sum(map_dbl(nb, at, "x")) - at(opp, "x")
  y_new <- sum(map_dbl(nb, at, "y")) - at(opp, "y")
  sep <- min(sqrt((q$x - x_new)^2 + (q$y - y_new)^2))
  if (sep < impute_min_sep) {
    warning(sprintf("quadrat %d: recorded corners %s are near-collinear (imputed %s would sit %.1f m from a recorded corner); not imputed",
                    q$sq_id[1], paste(sort(q$corner), collapse = ""), missing, sep), call. = FALSE)
    return(NULL)
  }
  tibble(
    raw_row         = NA_integer_,
    waypoint_raw    = NA_character_,
    waypoint_name   = paste0(q$sq_id[1], missing),
    collection_date = q$collection_date[1],
    notes           = NA_character_,
    correction      = "imputed: parallelogram completion of the three recorded corners",
    unit_type       = "quadrat",
    sq_id           = q$sq_id[1],
    corner          = missing,
    line_id         = NA_character_,
    point           = NA_character_,
    source          = "imputed",
    imputed         = TRUE,
    x               = x_new,
    y               = y_new
  )
}

imputed <- pts %>%
  filter(unit_type == "quadrat") %>%
  group_split(sq_id) %>%
  map(impute_corner) %>%
  compact()

if (length(imputed)) {
  imputed <- bind_rows(imputed) %>% to_lonlat()
  pts <- bind_rows(pts, imputed)
}

pts <- pts %>%
  arrange(unit_type, sq_id, corner, line_id, point) %>%
  select(waypoint_name, unit_type, sq_id, corner, line_id, point,
         lat, lon, x, y, collection_date, source, imputed, correction,
         raw_row, waypoint_raw, notes)

# quadrat geometry -------------------------------------------------------------

dist_between <- function(q, a, b) {
  if (!all(c(a, b) %in% q$corner)) return(NA_real_)
  i <- q$corner == a; j <- q$corner == b
  sqrt((q$x[i] - q$x[j])^2 + (q$y[i] - q$y[j])^2)
}

summarise_quadrat <- function(q) {
  tibble(
    sq_id           = q$sq_id[1],
    n_corners       = nrow(q),
    corners_present = paste(sort(q$corner), collapse = ""),
    n_imputed       = sum(q$imputed),
    x               = mean(q$x),
    y               = mean(q$y),
    side_ab         = dist_between(q, "A", "B"),
    side_bc         = dist_between(q, "B", "C"),
    side_cd         = dist_between(q, "C", "D"),
    side_da         = dist_between(q, "D", "A"),
    diag_ac         = dist_between(q, "A", "C"),
    diag_bd         = dist_between(q, "B", "D"),
    collection_date = min(q$collection_date)
  ) %>%
    mutate(
      # RMS departure of the six inter-corner distances from a 15 m square
      shape_rmse_m = sqrt(mean(c((side_ab - side_nominal)^2, (side_bc - side_nominal)^2,
                                 (side_cd - side_nominal)^2, (side_da - side_nominal)^2,
                                 (diag_ac - diag_nominal)^2, (diag_bd - diag_nominal)^2),
                               na.rm = TRUE)),
      geometry_flag = n_corners < 4 |
        !between(pmin(side_ab, side_bc, side_cd, side_da), side_ok[1], Inf) |
        !between(pmax(side_ab, side_bc, side_cd, side_da), -Inf, side_ok[2]) |
        !between(pmin(diag_ac, diag_bd), diag_ok[1], Inf) |
        !between(pmax(diag_ac, diag_bd), -Inf, diag_ok[2])
    )
}

quadrats <- pts %>%
  filter(unit_type == "quadrat") %>%
  group_split(sq_id) %>%
  map(summarise_quadrat) %>%
  bind_rows() %>%
  to_lonlat()

# nearest neighbouring quadrat, centroid to centroid — the input to the
# SQ-to-group derivation (protocol §2)
d <- as.matrix(dist(quadrats[, c("x", "y")]))
diag(d) <- NA
quadrats <- quadrats %>%
  mutate(
    nearest_sq = quadrats$sq_id[apply(d, 1, which.min)],
    nearest_m  = apply(d, 1, min, na.rm = TRUE)
  ) %>%
  select(sq_id, n_corners, corners_present, n_imputed, lat, lon, x, y,
         starts_with("side_"), starts_with("diag_"), shape_rmse_m, geometry_flag,
         nearest_sq, nearest_m, collection_date)

# pitfall lines ----------------------------------------------------------------

lines <- pts %>%
  filter(unit_type == "pitfall_line") %>%
  group_by(line_id) %>%
  summarise(
    n_points        = n(),
    span_m          = if (n() > 1) max(dist(cbind(x, y))) else NA_real_,
    x               = mean(x),
    y               = mean(y),
    collection_date = min(collection_date),
    .groups = "drop"
  ) %>%
  to_lonlat() %>%
  select(line_id, n_points, span_m, lat, lon, x, y, collection_date)

# write ------------------------------------------------------------------------

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(pts,      file.path(out_dir, "wp1_soil_points.csv"))
write_csv(quadrats, file.path(out_dir, "wp1_quadrats.csv"))
write_csv(lines,    file.path(out_dir, "wp1_pitfall_lines.csv"))

gpkg <- file.path(out_dir, "wp1_soil_points.gpkg")
if (file.exists(gpkg)) invisible(file.remove(gpkg))

vect(as.data.frame(pts), geom = c("x", "y"), crs = crs_tm35, keepgeom = TRUE) %>%
  writeVector(gpkg, layer = "soil_points")
vect(as.data.frame(quadrats), geom = c("x", "y"), crs = crs_tm35, keepgeom = TRUE) %>%
  writeVector(gpkg, layer = "quadrat_centroids", insert = TRUE)

complete <- quadrats %>% filter(n_corners == 4)
if (nrow(complete)) {
  ring <- pts %>%
    filter(unit_type == "quadrat", sq_id %in% complete$sq_id) %>%
    mutate(order = match(corner, names(opposite))) %>%
    arrange(sq_id, order)
  m <- cbind(id = match(ring$sq_id, complete$sq_id), part = 1, x = ring$x, y = ring$y, hole = 0)
  polys <- vect(m, type = "polygons", crs = crs_tm35)
  values(polys) <- as.data.frame(complete %>% select(sq_id, n_imputed, geometry_flag))
  writeVector(polys, gpkg, layer = "quadrat_polygons", insert = TRUE)
}

# report -----------------------------------------------------------------------

message(sprintf("raw rows %d; dropped by correction %d; exact duplicates collapsed %d; imputed corners %d; points out %d",
                nrow(raw), n_dropped, n_exact_dups, sum(pts$imputed), nrow(pts)))
message(sprintf("corrections applied: %d of %d", sum(!is.na(pts$correction) & !pts$imputed) + n_dropped, nrow(corrections)))
message(sprintf("quadrats %d (complete %d); pitfall lines %d",
                nrow(quadrats), sum(quadrats$n_corners == 4), nrow(lines)))

incomplete <- quadrats %>% filter(n_corners < 4)
if (nrow(incomplete)) {
  message("quadrats with fewer than four corners: ",
          paste(sprintf("%d (%s)", incomplete$sq_id, incomplete$corners_present), collapse = ", "))
}
flagged <- quadrats %>% filter(geometry_flag, n_corners == 4)
if (nrow(flagged)) {
  message("complete quadrats with sides outside ", side_ok[1], "-", side_ok[2],
          " m or diagonals outside ", diag_ok[1], "-", diag_ok[2], " m: ",
          paste(flagged$sq_id, collapse = ", "))
}
message(sprintf("shape RMSE across complete quadrats: median %.1f m, max %.1f m (sq %d)",
                median(complete$shape_rmse_m), max(complete$shape_rmse_m),
                complete$sq_id[which.max(complete$shape_rmse_m)]))
