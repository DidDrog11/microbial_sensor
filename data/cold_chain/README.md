# cold_chain

Tidied temperature-logger series for sample transport and storage. Contents are gitignored; the raw exports live in `data-raw/`.

| File | Built by | Content |
|---|---|---|
| `wp1_freezer_logger.csv` | `R/04_wp1_freezer_logger.R` | one row per 5-minute reading from the car freezer, Pallasjärvi to Uppsala, September 2026; local time (UTC+02:00) |
| `wp1_freezer_logger_summary.csv` | same | trip summary and time above each threshold |

The figure is `output/figures/wp1_freezer_logger.png`.
