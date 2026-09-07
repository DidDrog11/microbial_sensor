# field_sites

Tidied field site geometry — trap-grid corners, quadrat centroids, and related spatial reference tables. Contents are gitignored.

Built by `R/01_wp1_trap_grid_gpx.R` from the GPX exports in `data-raw/wp1_finland/sampling/`. The `source` column in each table records the GPX file a row came from.

These tables hold quadrat **corners**, not trap station positions. Station positions within a quadrat are not in the GPX exports.
