# 02_build_kobo_forms.R --------------------------------------------------------
#
# Build the three WP1 KoBo data-capture forms as XLSForms.
#
# Output  data-capture/wp1_voles.xlsx
#         data-capture/wp1_soil.xlsx
#         data-capture/wp1_nest.xlsx
#
# The shared location block is defined once, here, and pasted into all three
# forms. That block is the join key between the three tables and to Henttonen's
# morphometrics, so the field names must match exactly across forms — which is
# why these are generated rather than maintained as three spreadsheets.
#
# Upload each .xlsx to KoBoToolbox with "New project -> Upload an XLSForm".
# Bump FORM_VERSION whenever a form changes; KoBo uses it to version submissions.

library(dplyr)
library(tibble)
library(writexl)
library(here)

out_dir <- here("data-capture")

FORM_VERSION <- "2026-09-07"

# shared blocks ----------------------------------------------------------------

# Columns every survey sheet carries. Kept in one place so the three sheets bind
# cleanly even when a form uses none of a given column.
survey_row <- function(type, name, label, required = NA, relevant = NA,
                       constraint = NA, constraint_message = NA,
                       hint = NA, appearance = NA) {
  tibble(type, name, label, required, relevant,
         constraint, constraint_message, hint, appearance)
}

#' Device metadata — invisible to the enumerator, useful for QA
meta_block <- function() {
  bind_rows(
    survey_row("start",    "start",    NA),
    survey_row("end",      "end",      NA),
    survey_row("deviceid", "deviceid", NA)
  )
}

#' The join key. Identical field names and types in all three forms.
location_block <- function() {
  bind_rows(
    survey_row("date", "collection_date", "Date",
               required = "yes"),
    survey_row("text", "group_id", "Group ID",
               required = "yes",
               hint = "Trapping group, as labelled by the Henttonen team"),
    # Not required: off-grid reference soil sits outside any quadrat, and nest
    # material is linked to the SQ rather than to a corner. Leaving these blank
    # is a valid record, so a required flag here would block real samples.
    survey_row("integer", "sq_id", "Small quadrat (SQ) ID",
               constraint = ". > 0",
               constraint_message = "Must be a positive whole number",
               hint = "e.g. 31. Leave blank for off-grid reference samples"),
    survey_row("text", "capture_point_id", "Capture point ID",
               hint = "Quadrat corner as labelled on the ground, e.g. A, B, C, D. Leave blank if not at a corner"),
    survey_row("select_one habitat", "habitat", "Habitat",
               required = "yes",
               appearance = "minimal"),
    survey_row("text", "collector_initials", "Collector initials",
               required = "yes",
               constraint = "regex(., '^[A-Za-z]{2,4}$')",
               constraint_message = "Two to four letters")
  )
}

habitat_choices <- function() {
  tribble(
    ~list_name,  ~name,        ~label,
    "habitat",   "old_forest", "Old forest",
    "habitat",   "peatland",   "Peatland"
  )
}

settings_sheet <- function(title, id) {
  tibble(form_title = title, form_id = id, version = FORM_VERSION)
}

# form 1 — voles ---------------------------------------------------------------

voles_form <- function() {
  survey <- bind_rows(
    meta_block(),
    location_block(),
    survey_row("text", "animal_id", "Animal ID (Henttonen)",
               required = "yes",
               hint = "Required — this is what joins to the morphometrics"),
    survey_row("text", "caecum_sample_id", "Caecum sample ID",
               required = "yes"),
    survey_row("text", "colon_sample_id", "Distal colon sample ID",
               required = "yes"),
    survey_row("time", "trap_check_time", "Time of trap check",
               required = "yes"),
    survey_row("time", "dissection_time", "Time of dissection",
               required = "yes",
               hint = "The gap from trap check is the post-mortem interval"),
    survey_row("select_one gut_fullness", "gut_fullness", "Gut fullness",
               required = "yes",
               appearance = "minimal"),
    survey_row("select_one yes_no", "caecum_torn", "Caecum torn during dissection?",
               required = "yes",
               hint = "A tear cross-contaminates caecum and colon",
               appearance = "minimal"),
    survey_row("text", "dissector_initials", "Dissector initials",
               required = "yes",
               constraint = "regex(., '^[A-Za-z]{2,4}$')",
               constraint_message = "Two to four letters"),
    survey_row("text", "notes", "Notes", appearance = "multiline")
  )

  choices <- bind_rows(
    habitat_choices(),
    tribble(
      ~list_name,      ~name,     ~label,
      "gut_fullness",  "full",    "Full",
      "gut_fullness",  "partial", "Partial",
      "gut_fullness",  "empty",   "Empty",
      "yes_no",        "yes",     "Yes",
      "yes_no",        "no",      "No"
    )
  )

  list(survey = survey, choices = choices,
       settings = settings_sheet("WP1 Pallasjärvi — Voles", "wp1_voles"))
}

# form 2 — soil ----------------------------------------------------------------

# Field blanks ride on this form as a sample_type rather than a fourth form, so
# a blank is recorded at the moment it is opened. The soil-specific questions
# are hidden when sample_type is a blank.
soil_form <- function() {
  is_soil <- "${sample_type} = 'soil'"

  survey <- bind_rows(
    meta_block(),
    location_block(),
    survey_row("select_one soil_sample_type", "sample_type", "Sample type",
               required = "yes",
               appearance = "minimal"),
    survey_row("text", "sample_id", "Sample ID",
               required = "yes"),
    survey_row("decimal", "depth_cm", "Sampling depth (cm below litter)",
               required = "yes",
               relevant = is_soil,
               constraint = ". >= 0 and . <= 50",
               constraint_message = "Expected 0-50 cm; add a note if genuinely deeper"),
    survey_row("select_one moisture", "moisture", "Moisture",
               required = "yes",
               relevant = is_soil,
               appearance = "minimal"),
    survey_row("select_one position", "position", "Position",
               required = "yes",
               relevant = is_soil,
               appearance = "minimal"),
    survey_row("text", "notes", "Notes", appearance = "multiline")
  )

  choices <- bind_rows(
    habitat_choices(),
    tribble(
      ~list_name,          ~name,                 ~label,
      "soil_sample_type",  "soil",                "Soil sample",
      "soil_sample_type",  "field_blank",         "Field blank",
      "moisture",          "dry",                 "Dry",
      "moisture",          "moist",               "Moist",
      "moisture",          "saturated",           "Saturated",
      "position",          "within_quadrat",      "Within quadrat",
      "position",          "quadrat_edge",        "Quadrat edge",
      "position",          "off_grid_reference",  "Off-grid reference"
    )
  )

  list(survey = survey, choices = choices,
       settings = settings_sheet("WP1 Pallasjärvi — Soil", "wp1_soil"))
}

# form 3 — nest and burrow material --------------------------------------------

nest_form <- function() {
  survey <- bind_rows(
    meta_block(),
    location_block(),
    survey_row("text", "sample_id", "Sample ID",
               required = "yes"),
    survey_row("select_one material_type", "material_type", "Material type",
               required = "yes",
               hint = "These are microbiologically different things",
               appearance = "minimal"),
    survey_row("text", "notes", "Notes", appearance = "multiline")
  )

  choices <- bind_rows(
    habitat_choices(),
    tribble(
      ~list_name,       ~name,            ~label,
      "material_type",  "nest",           "Actual nest",
      "material_type",  "burrow_lining",  "Burrow lining",
      "material_type",  "runway_debris",  "Runway debris"
    )
  )

  list(survey = survey, choices = choices,
       settings = settings_sheet("WP1 Pallasjärvi — Nest and burrow material", "wp1_nest"))
}

# run --------------------------------------------------------------------------

forms <- list(
  wp1_voles = voles_form(),
  wp1_soil  = soil_form(),
  wp1_nest  = nest_form()
)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

for (nm in names(forms)) {
  write_xlsx(forms[[nm]], file.path(out_dir, paste0(nm, ".xlsx")))
}

# check the join key really is identical across the three forms
location_names <- lapply(forms, function(f) {
  keep <- f$survey$name %in% location_block()$name
  f$survey$name[keep]
})
stopifnot(length(unique(location_names)) == 1)

message(sprintf("wrote %d forms to %s", length(forms), out_dir))
message(sprintf("shared location block (%d fields): %s",
                length(location_names[[1]]), paste(location_names[[1]], collapse = ", ")))
for (nm in names(forms)) {
  message(sprintf("  %-10s %2d questions, %2d choices",
                  nm, nrow(forms[[nm]]$survey), nrow(forms[[nm]]$choices)))
}
