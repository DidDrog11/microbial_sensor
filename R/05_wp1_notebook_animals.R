# 05_wp1_notebook_animals.R ----------------------------------------------------
#
# Parse the transcription of Henttonen's field notebook into one row per
# animal, map his species codes, and propose project sample codes for the
# bank voles.
#
# Input   data-raw/wp1_finland/henttonen/notebook.md   (transcribed by hand from
#                                                       photographs of the
#                                                       notebook; Henttonen's
#                                                       material, gitignored)
# Output  data/wp1_notebook_animals.csv                one row per animal (regenerated)
#         data/registry/wp1_sample_codes.csv           animal_id -> P-NNN (tracked, append-only)
#
# The notebook is organised as date headings ("13/9/2026"), "Location X"
# lines, and numbered animals ("5. Cgl"). Numbers restart each day, so the
# animal key is date + number, which is also what is written on the gut bags.
#
# Sample codes. Every animal in the notebook gets a project code P-NNN, all
# species, in chronological order (date, then Henttonen's number). Codes are
# held in a REGISTRY that this script reads first and only appends to: an
# animal already in the registry keeps its code whatever else changes, and
# new animals (later notebook pages) are numbered after the current maximum.
# Whether a gut bag exists for an animal, and which organs, is recorded in
# the vole table against the code, not by whether a code exists. Nothing is
# written on a cryovial until the registry row exists.

library(dplyr)
library(readr)
library(stringr)
library(tibble)
library(here)

nb_path  <- here("data-raw", "wp1_finland", "henttonen", "notebook.md")
out_dir  <- here("data")
reg_path <- here("data", "registry", "wp1_sample_codes.csv")

# species codes ----------------------------------------------------------------

# `confidence`: "sure" where the code is a standard Finnish small-mammal
# abbreviation and unambiguous; "likely" where the reading is plausible but
# should be checked against the photograph; "unknown" otherwise.
species_codes <- tribble(
  ~code,     ~species,                     ~common,               ~confidence,
  "Cgl",     "Clethrionomys glareolus",    "bank vole",           "sure",
  "Cut",     "Clethrionomys rutilus",      "red vole",            "likely",
  "Cufo",    "Clethrionomys rufocanus",    "grey-sided vole",     "likely",
  "Myopus",  "Myopus schisticolor",        "wood lemming",        "sure",
  "San",     "Sorex araneus",              "common shrew",        "sure",
  "Sc",      "Sorex caecutiens",           "masked shrew",        "likely",
  "S",       "Sorex sp.",                  "shrew, unidentified", "likely",
  # 7 Sep row 4: the photograph reads "Cut", not "Lut"
  "Lut",     "Clethrionomys rutilus",      "red vole",            "likely",
  # 7 Sep row 19: the photograph reads "gl" (adult male, 24 g, 103 mm), i.e. a bank vole
  "Gle",     "Clethrionomys glareolus",    "bank vole",           "likely",
  "Ad",      NA,                           NA,                    "unknown",
  "Nat",     NA,                           NA,                    "unknown"
)

# parse ------------------------------------------------------------------------

lines <- read_lines(nb_path) %>% str_trim() %>% .[. != ""]

is_date <- str_detect(lines, "^\\d{1,2}/\\d{1,2}/\\d{4}$")
is_loc  <- str_detect(lines, "^Location\\b")
is_anim <- str_detect(lines, "^\\d+[A-Za-z]?\\.\\s")

stopifnot(all(is_date | is_loc | is_anim))

rows <- list()
cur_date <- NA; cur_loc <- NA_character_; loc_line <- NA_integer_
for (i in seq_along(lines)) {
  l <- lines[i]
  if (is_date[i]) {
    cur_date <- as.Date(l, format = "%d/%m/%Y")
    cur_loc  <- NA_character_          # a new day has no location until stated
    next
  }
  if (is_loc[i]) {
    cur_loc <- str_trim(str_remove(l, "^Location\\s*"))
    next
  }
  num  <- str_extract(l, "^\\d+[A-Za-z]?")
  rest <- str_trim(str_remove(l, "^\\d+[A-Za-z]?\\.\\s*"))
  code <- str_extract(rest, "^[A-Za-z]+")
  note <- str_trim(str_remove(rest, "^[A-Za-z]+"))
  rows[[length(rows) + 1]] <- tibble(
    date = cur_date, location_raw = cur_loc, number_raw = num,
    species_code = code, notebook_note = if (note == "") NA_character_ else note,
    line_no = i
  )
}
animals <- bind_rows(rows)

# interpret --------------------------------------------------------------------

animals <- animals %>%
  mutate(
    # "Assume also S" and similar are transcription notes, not codes
    species_code = if_else(species_code == "Assume", "S", species_code),
    number       = suppressWarnings(as.integer(str_extract(number_raw, "^\\d+"))),
    number_suffix = str_extract(number_raw, "[A-Za-z]$"),
    animal_id    = paste0(format(date, "%Y%m%d"), "-", str_pad(number_raw, 2, pad = "0")),
    # units: a bare integer is a small quadrat; anything else is a line or a
    # named place. "extra" on 6 Sep carries coordinates that put it at LOM.
    sq_id   = suppressWarnings(as.integer(if_else(str_detect(location_raw, "^\\d+$"), location_raw, NA_character_))),
    line_id = case_when(
      is.na(location_raw)                       ~ NA_character_,
      !is.na(sq_id)                             ~ NA_character_,
      location_raw == "MS"                      ~ "MS",
      location_raw == "8-10"                    ~ "8-10",
      location_raw == "extra" & date == as.Date("2026-09-06") ~ "LOM",
      TRUE                                      ~ location_raw
    ),
    unit_known = !is.na(location_raw),
    soil_sampled_unit = sq_id %in% c(31:48, 54:60) | line_id %in% c("MS", "MS+", "8-10", "LOM")
  ) %>%
  left_join(species_codes, by = c("species_code" = "code")) %>%
  mutate(confidence = if_else(is.na(confidence), "unknown", confidence)) %>%
  arrange(date, number, number_suffix)

animals <- animals %>%
  mutate(is_bank_vole = !is.na(species) & species == "Clethrionomys glareolus")

# checks -----------------------------------------------------------------------

dup <- animals %>% count(animal_id) %>% filter(n > 1)
if (nrow(dup)) stop("duplicate animal_id: ", paste(dup$animal_id, collapse = ", "))

# registry: read, append new animals, never renumber ---------------------------

registry <- if (file.exists(reg_path)) {
  read_csv(reg_path, col_types = cols(.default = col_character(), date = col_date()))
} else {
  tibble(animal_id = character(), sample_code = character(), date = as.Date(character()),
         number_raw = character(), location_raw = character(), species_code = character(),
         assigned_on = character())
}

# an animal already registered must still read the same in the notebook
chk <- registry %>%
  inner_join(animals %>% select(animal_id, nb_species = species_code, nb_location = location_raw),
             by = "animal_id") %>%
  filter(nb_species != species_code | coalesce(nb_location, "") != coalesce(location_raw, ""))
if (nrow(chk)) {
  warning("registered animals whose notebook species or location has changed (registry kept as is): ",
          paste(chk$animal_id, collapse = ", "), call. = FALSE)
}

new <- animals %>%
  filter(!animal_id %in% registry$animal_id) %>%
  arrange(date, number, number_suffix)

next_n <- if (nrow(registry)) max(as.integer(str_extract(registry$sample_code, "\\d+$"))) else 0L
if (nrow(new)) {
  new <- new %>%
    transmute(animal_id,
              sample_code = paste0("P-", str_pad(next_n + row_number(), 3, pad = "0")),
              date, number_raw, location_raw, species_code,
              assigned_on = format(Sys.Date()))
  registry <- bind_rows(registry, new)
}

stopifnot(!any(duplicated(registry$sample_code)), !any(duplicated(registry$animal_id)))

animals <- animals %>%
  left_join(registry %>% select(animal_id, sample_code), by = "animal_id") %>%
  select(animal_id, sample_code, date, number_raw, location_raw, sq_id, line_id, unit_known,
         soil_sampled_unit, species_code, species, common, confidence, is_bank_vole,
         notebook_note, line_no)

# write ------------------------------------------------------------------------

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(reg_path), recursive = TRUE, showWarnings = FALSE)
write_csv(animals, file.path(out_dir, "wp1_notebook_animals.csv"))
write_csv(registry, reg_path)

# pre-filled vole sheet in the schema of data-capture/wp1_voles_template.csv:
# everything the notebook gives, blanks for what is filled at the freezer or
# comes from Henttonen's sheet. Copy to data-raw/wp1_finland/wp1_voles.csv and
# fill gut_bag, gut_fullness and caecum_torn against the bags.
template_cols <- names(read_csv(here("data-capture", "wp1_voles_template.csv"),
                                col_types = cols(.default = col_character()), n_max = 0))
prefill <- animals %>%
  transmute(
    processing_date = format(date),            # notebook date = day of check and necropsy
    animal_id, sample_code,
    capture_date    = format(date),
    sq_id           = as.character(sq_id),
    line_id,
    habitat         = if_else(soil_sampled_unit, "old_forest", NA_character_),
    species,
    notes           = case_when(
      confidence == "unknown" ~ paste0("species code '", species_code, "' not read"),
      confidence == "likely"  ~ paste0("species from code '", species_code, "', check against sheet"),
      !unit_known             ~ "no location written in notebook for this row",
      TRUE                    ~ NA_character_
    )
  )
for (col in setdiff(template_cols, names(prefill))) prefill[[col]] <- NA_character_
prefill <- prefill[, template_cols]
write_csv(prefill, file.path(out_dir, "wp1_voles_prefill.csv"), na = "")
message(sprintf("registry: %d animals, %d newly assigned (%s)",
                nrow(registry), nrow(new),
                if (nrow(new)) paste(range(new$sample_code), collapse = " to ") else "none"))

# report -----------------------------------------------------------------------

message(sprintf("%d animals, %s to %s, %d days",
                nrow(animals), format(min(animals$date)), format(max(animals$date)), n_distinct(animals$date)))
message("species: ", paste(sprintf("%s=%d", names(table(animals$species_code)), table(animals$species_code)), collapse = ", "))
message(sprintf("bank voles: %d in total; %d on soil-sampled units; %d with no location stated",
                sum(animals$is_bank_vole),
                sum(animals$is_bank_vole & animals$soil_sampled_unit),
                sum(animals$is_bank_vole & !animals$unit_known)))
bv <- animals %>% filter(is_bank_vole) %>% count(date, name = "n_bank_voles")
message("bank voles by day: ", paste(sprintf("%s=%d", format(bv$date, "%d %b"), bv$n_bank_voles), collapse = ", "))
locs <- animals %>% filter(is_bank_vole) %>% count(location_raw, sq_id, line_id, soil_sampled_unit) %>% arrange(desc(n))
message("bank voles by location (location_raw: n, soil-sampled?): ",
        paste(sprintf("%s: %d%s", coalesce(locs$location_raw, "<none>"), locs$n, if_else(locs$soil_sampled_unit, "", " *")), collapse = "; "))
message("unknown codes: ", paste(unique(animals$species_code[animals$confidence == "unknown"]), collapse = ", "))
