# data-capture

KoBoToolbox data-capture forms for the WP1 Pallasjärvi campaign, as XLSForms.

| File | Form | One row per |
|---|---|---|
| `wp1_voles.xlsx` | WP1 Pallasjärvi — Voles | trapped animal |
| `wp1_soil.xlsx` | WP1 Pallasjärvi — Soil | soil sample or field blank |
| `wp1_nest.xlsx` | WP1 Pallasjärvi — Nest and burrow material | nest/burrow sample |

## The join key

All three forms open with the same six location fields, identical in name and type. This block is what joins the three tables to each other, and the vole form's `animal_id` is what joins to Henttonen's morphometrics.

| Field | Type | Required |
|---|---|---|
| `collection_date` | date | yes |
| `group_id` | text | yes |
| `sq_id` | integer | no — blank for off-grid reference samples |
| `capture_point_id` | text | no — blank when not at a quadrat corner |
| `habitat` | select_one (old forest / peatland) | yes |
| `collector_initials` | text | yes |

Each form also carries `start`, `end` and `deviceid` metadata, which KoBo fills automatically.

## Field blanks

Blanks are recorded on the **soil** form, via a `sample_type` question (soil sample / field blank), rather than as a fourth form. A blank is opened at a sampling point during soil collection, so this puts the record at the moment it happens instead of relying on someone remembering afterwards. When `sample_type` is a blank, the soil-specific questions (depth, moisture, position) are hidden.

## Regenerating

Do not edit these files by hand — the shared location block would drift between them. Edit `R/02_build_kobo_forms.R` and re-run it:

```r
source(here::here("R", "02_build_kobo_forms.R"))
```

The script asserts that the location block is identical across all three forms before it finishes. Bump `FORM_VERSION` in the script whenever a form changes; KoBo uses it to version submissions.

## Uploading

In KoBoToolbox: **New project → Upload an XLSForm**, once per file. KoBo validates the form on upload and will report any XLSForm error.
