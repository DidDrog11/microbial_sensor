# 04_wp1_freezer_logger.R ------------------------------------------------------
#
# Parse the Freshliance Fresh Tag 1 export from the car-freezer logger into a
# tidy series, summarise the cold chain, and plot it.
#
# Input   data-raw/wp1_finland/wp1_freezer_logger.csv   (read-only, as exported)
# Output  data/cold_chain/wp1_freezer_logger.csv         one row per reading
#         data/cold_chain/wp1_freezer_logger_summary.csv
#         output/figures/wp1_freezer_logger.png
#
# The export has a free-text header (device, summary block) with embedded NUL
# bytes, then a data block headed "MM/DD/YY,HH/MM/SS,Centigrade,Fahrenheit,
# Status". Times are local (UTC+02:00 per the header). The parser finds the
# data block by its header line rather than by counting rows.

library(dplyr)
library(readr)
library(stringr)
library(tibble)
library(ggplot2)
library(here)

raw_path <- here("data-raw", "wp1_finland", "wp1_freezer_logger.csv")
out_dir  <- here("data", "cold_chain")
fig_dir  <- here("output", "figures")

# thresholds reported on: the freezer set point, and two levels a reviewer
# might ask about
thresholds <- c(-15, -10, -5, 0)

# read -------------------------------------------------------------------------

lines <- readBin(raw_path, what = "raw", n = file.size(raw_path)) %>%
  .[. != as.raw(0)] %>%                       # drop NUL bytes
  rawToChar() %>%
  str_split("\r?\n") %>%
  .[[1]] %>%
  str_trim()

tz_note <- lines[str_detect(lines, "UTC")] %>% str_extract("UTC[+-]\\d{2}:\\d{2}")
interval <- lines[str_detect(lines, "Log Interval")] %>% str_extract("\\d+ min")
device   <- lines[str_detect(lines, "^Device ID")] %>% str_extract("(?<=Device ID:,)[^,]+")

hdr <- which(str_detect(lines, "^MM/DD/YY,HH"))
stopifnot(length(hdr) == 1)

# data rows are "date,time,C,F" with an optional trailing status field
fields <- str_split_fixed(lines[(hdr + 1):length(lines)], ",", n = 5)
colnames(fields) <- c("date", "time", "temp_c", "temp_f", "status")

readings <- as_tibble(fields) %>%
  filter(str_detect(date, "^\\d{2}/\\d{2}/\\d{2}$")) %>%
  transmute(
    datetime = as.POSIXct(paste(date, time), format = "%m/%d/%y %H:%M:%S", tz = "Etc/GMT-2"),
    temp_c   = as.numeric(temp_c),
    status   = na_if(str_trim(status), "")
  ) %>%
  arrange(datetime)

stopifnot(nrow(readings) > 0, !any(is.na(readings$datetime)), !any(is.na(readings$temp_c)))

step_min <- as.numeric(median(diff(readings$datetime)), units = "mins")

# summarise --------------------------------------------------------------------

# length of the longest continuous run above a threshold, in minutes
longest_run <- function(x, thr, step) {
  r <- rle(x > thr)
  if (!any(r$values)) return(0)
  max(r$lengths[r$values]) * step
}

summary_tbl <- tibble(
  device            = device,
  timezone          = tz_note,
  interval          = interval,
  start             = min(readings$datetime),
  end               = max(readings$datetime),
  n_readings        = nrow(readings),
  duration_h        = round(as.numeric(difftime(max(readings$datetime), min(readings$datetime), units = "hours")), 1),
  max_c             = max(readings$temp_c),
  max_at            = readings$datetime[which.max(readings$temp_c)],
  min_c             = min(readings$temp_c),
  mean_c            = round(mean(readings$temp_c), 1),
  median_c          = median(readings$temp_c)
)

above <- bind_rows(lapply(thresholds, function(thr) {
  tibble(
    threshold_c     = thr,
    minutes_above   = sum(readings$temp_c > thr) * step_min,
    pct_time_above  = round(100 * mean(readings$temp_c > thr), 1),
    longest_run_min = longest_run(readings$temp_c, thr, step_min)
  )
}))

# write ------------------------------------------------------------------------

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(readings, file.path(out_dir, "wp1_freezer_logger.csv"))
write_csv(bind_cols(summary_tbl[rep(1, nrow(above)), ], above),
          file.path(out_dir, "wp1_freezer_logger_summary.csv"))

p <- ggplot(readings, aes(datetime, temp_c)) +
  geom_hline(yintercept = c(0, -18), linetype = c("solid", "dashed"), colour = "grey50") +
  geom_line(linewidth = 0.3) +
  scale_x_datetime(date_breaks = "1 day", date_labels = "%d %b") +
  labs(x = NULL, y = "Air temperature in car freezer (°C)",
       title = "WP1 car freezer, Pallasjärvi to Uppsala",
       subtitle = sprintf("%s readings at %s; dashed line is the −18 °C set point",
                          format(nrow(readings), big.mark = ","), interval)) +
  theme_minimal(base_size = 11)
ggsave(file.path(fig_dir, "wp1_freezer_logger.png"), p, width = 9, height = 4, dpi = 150)

# report -----------------------------------------------------------------------

message(sprintf("%s readings every %.0f min, %s to %s (%s), %.1f h",
                nrow(readings), step_min,
                format(summary_tbl$start, "%d %b %H:%M"), format(summary_tbl$end, "%d %b %H:%M"),
                tz_note, summary_tbl$duration_h))
message(sprintf("max %.1f °C at %s; min %.1f °C; mean %.1f; median %.1f",
                summary_tbl$max_c, format(summary_tbl$max_at, "%d %b %H:%M"),
                summary_tbl$min_c, summary_tbl$mean_c, summary_tbl$median_c))
for (i in seq_len(nrow(above))) {
  message(sprintf("above %3d °C: %5.0f min (%4.1f%% of trip), longest continuous run %.0f min",
                  above$threshold_c[i], above$minutes_above[i], above$pct_time_above[i], above$longest_run_min[i]))
}
