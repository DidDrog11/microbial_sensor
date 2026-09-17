# field_sites

Tidied field site geometry — soil points, quadrat centroids and polygons, pitfall lines, and related spatial reference tables. Contents are gitignored.

## WP1 soil points (September 2026 campaign)

Built by `R/03_wp1_soil_point_coords.R` from the hand-entered waypoints in `data-raw/wp1_finland/wp1_corner_coords.csv`.

| File | One row per | Notes |
|---|---|---|
| `wp1_soil_points.csv` | soil point (quadrat corner or pitfall point) | `source` is `gps` or `imputed`; `correction` records any departure from the raw row; `raw_row` and `waypoint_raw` trace back to the file as entered |
| `wp1_quadrats.csv` | quadrat | centroid, side and diagonal lengths, `geometry_flag`, nearest neighbouring quadrat — the input to the SQ-to-group derivation |
| `wp1_pitfall_lines.csv` | pitfall line | span between the recorded points |
| `wp1_soil_points.gpkg` | — | layers `soil_points`, `quadrat_centroids`, `quadrat_polygons` (complete quadrats only), EPSG:3067 |

The raw file is never edited. Corrections live in the `corrections` table at the top of the script, matched on the waypoint name and the coordinates as entered, so each applies exactly once and warns if the raw row changes. A quadrat with three recorded corners gets its fourth by parallelogram completion, flagged `imputed`.

## Henttonen trap-grid GPX

`R/01_wp1_trap_grid_gpx.R` parses Garmin GPX exports of the trap-grid corners from `data-raw/wp1_finland/henttonen/` into `wp1_trap_grid_*` tables. The `source` column records the GPX file a row came from. These are quadrat corners, not trap positions: three snap traps sit within a few metres of each corner and are not recorded.
