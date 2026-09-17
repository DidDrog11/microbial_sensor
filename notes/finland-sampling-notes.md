# Finland — WP1 field log

Companion to `docs/protocols/pallasjarvi-fieldwork-protocol.qmd`, which is authoritative for sampling, cold chain and data capture. This file records what happened each day and any deviation from the protocol. The pre-departure shopping and to-do lists that used to live here are done and have been removed; the design points they raised are now in the protocol (§2, §5.3, §5.6).

## 2026-09-14 — soil, morning 1

- 10 SQ covered, 50 tubes: 4 corner soils + 1 field blank per SQ. SQs 31–37 and 58–60, all old forest.
- Group not recorded; to be derived from the corner GPS afterwards.
- Traps confirmed at the corners: 3 snap traps per corner, within ~3–5 m of the marker. Trap positions not recorded. Animals are recorded to SQ only in Henttonen's data, not to corner.
- Soil from the nearest runway or burrow opening to each corner, 2 cm below the litter and needle layer, 2 ml tube. Fresh spatula and gloves per tube.
- One GPS waypoint per corner, taken with our handheld unit.
- Tubes labelled SQ number + corner letter (e.g. `31A`). Blanks labelled SQ number + "control" this morning; from tomorrow the SQ number alone. Blank always opened at corner A.
- Runway vs. burrow opening not distinguished, by decision: uncontrolled covariate at a fixed horizon.
- No nest material: burrows are too deep to reach it. Nest sampling dropped (protocol §5.4).
- Station freezer working; tubes moved there after the morning. Car freezer on mains at the station, logger and gel packs in.
- KoBo not used. Soil and vole data transcribed each evening into the templates in `data-capture/` (protocol §8). Vole data are entered by Henttonen; his record holds trap-check and dissection times. Gut fullness and caecum state are recorded at dissection for the animals we sample; so far every colon and caecum has contained faeces. We transcribe the rows for the animals whose gut we take.

Still open, from protocol §11: reference soils (4 forest + 4 peatland) not yet collected.

## 2026-09-14 — soil, afternoon

- SQs 38–43 sampled (6 SQ, 30 tubes), old forest. Running total 16 SQ.
- Two **pitfall lines** also sampled, `MS` and `MS+` ("MS extra"), old forest: 2 soils + 1 blank per line, coordinates taken for each soil. Tubes read "MS 1", "MS 2", "MS (blank)", "MS+ 1", "MS+ 2", "MS+ (blank)"; data IDs `MS1`, `MS2`, `MS`, `MS+1`, `MS+2`, `MS+`.
- About 6 voles from the pitfall lines, recorded to line only. Line length and pitfall spacing unknown; infer from coordinates or ask Heikki.
- Pitfalls are a different unit from an SQ (shape, extent, trap type, soil coverage). Whether these voles can enter the dyadic model is open (protocol §11); data collected so the option exists.
- Vole data: Heikki will share his Excel sheet rather than have us read the lab notes. His sheet is the primary record; we fill only sample IDs, gut fullness and caecum torn per animal, keyed on his animal ID. Animal ID confirmed identical to the gut bags. **The SQ or line an animal came from is only in his notebook**, not the sheet: extract animal ID + unit every evening while the notebook is available.
- End of day: all 86 tubes (16 SQ × 5, plus 6 from the two pitfall lines) checked into the travel freezer. Soil log written for the day. A couple of tubes have a numbering doubt; they are logged normally and will be given `flag = label_concern` at the Uppsala freezer check-in once the labels are read again, not before.
- Repository policy changed today: `data-raw/` is now tracked (small, hand-entered, irreplaceable) with a 50 MB pre-commit guard. Heikki's own material goes in `data-raw/wp1_finland/henttonen/`, which stays ignored on this public repo unless he agrees to release.
- `line_id` column added to all three tables.
- Coordinates for the day entered by hand into `data-raw/wp1_finland/wp1_corner_coords.csv` (68 rows). QC found: 38A longitude typed as 42D's; 42B entered as a copy of 42A; 43 entered twice, second set kept with A latitude 68.01781 → 68.01681; a "40B" in the 41 sequence is 41B; the southern of two sets entered as 35 is 34; 36D and 59B never recorded, to be imputed; 58A and 58D never recorded, to be taken at the trap check on 15 Sep. Raw file left as entered; all fixes live in the corrections table in `R/03_wp1_soil_point_coords.R`.
- Geometry after corrections: nearest-neighbour centroid spacing 49–79 m, as designed. Within-quadrat shape residuals are larger than 2 m GPS error alone would give (sides 6–29 m against a nominal 15, median shape RMSE ~4 m), but the residual mixes GPS error with how square the quadrats are on the ground, and the unit reports no uncertainty. Open sky, fixes taken clear of trees. To separate the two: re-record one already-recorded quadrat at a later visit; repeat fixes give an empirical precision estimate the unit will not. Centroids are fine either way; corner-to-corner distances are not used, as the protocol assumes. 36's three recorded points are collinear (A–B–C in a 24 m line), so its fourth corner cannot be imputed; 59B imputed. 42C corrected on the unit (latitude had been typed as 42D's). 38 re-read against the unit and stands as recorded: B really is 29 m from A and 10 m from C, so either the fix was poor or the quadrat is not square there. Heikki's own GPS points for the quadrats may follow; ours are where the soil was taken and are used until then.

## 2026-09-15 — soil

- **No bank voles caught on the peatland grids.** WP1 is old forest only; the forest/peatland contrast is gone, peatland reference soils dropped. Protocol §2, §5.5, §5.6 updated. The 25 SQs sampled (31–48, 54–60) are the full forest set. Checked the funded proposal: it never mentions peatland or a habitat contrast, so no commitment is affected; the contrast only ever existed in the protocol draft.
- SQs 44–48 and 54–57 sampled (9 SQ, 45 tubes), old forest. Running total 25 SQ.
- Two trap lines, not grids: `8-10` (tubes "8-10 A", "8-10 B", "8-10 (blank)") and `LOM` ("LOM-A", "LOM-B", "LOM (blank)"). Data IDs `8-10A`, `8-10B`, `8-10`; `LOM-A`, `LOM-B`, `LOM`. Handled as `line_id` units like MS and MS+.
- Reference soils REF1 and REF2, old forest. REF3 and REF4 tomorrow.
- 53 tubes today; 139 in total.
- Coordinates for today, plus 58A/58D and the re-recorded 36, to be entered and shared later; the loader now parses lettered line points and plain REF numbers.
- Trap check and dissection SOP recorded in protocol §5.0–5.1: walks from 09:00, bags per SQ, carcasses to the lab freezer straight after each group, dissected one at a time the same day, chilled not thawed. New tweezers for the abdomen and new utensils for the gut per animal; gut bags labelled date + rodent number + organ, straight to the freezer. Heikki assigns functional group (age, sex, maturity). Mornings ~1 °C, nights ~0 °C, so the pre-collection interval is cold.
- Gut sample IDs are now derived from Heikki's rodent number (`{id}-CAE`, `{id}-COL`), not assigned separately.
- Rodent numbers restart each day, so `animal_id` is date + number (`20260915-07`) and gut IDs `20260915-07-CAE` / `-COL`. Tools rotate between animals via bleach immersion, rinse, second bleach bath; concentration, immersion time and rinse water still to record.
- Tools sit ~30 min in the second bleach bath (lab-grade bleach, concentration to ask). Gloves changed per animal; gut touched only with tools. Whole caecum and whole colon bagged with contents; subsampling to pellets/content vs. wall is a processing decision, flagged in protocol §5.1 and §10 for the lab protocol. No scavenged or damaged carcasses so far.

## 2026-09-17 — Henttonen GPX

- Heikki shared a second GPX; both files are his own corner fixes from 4 Sep 2025. Together they cover SQs 31–43 (52 waypoints; 31C and 42D absent, extra "31B1", "42C1", "40c") and 49–53 (20 waypoints; 52D absent, extra "52C1"). Not covered: 44–48, 54–60. His unit recorded no hdop/satellite fields. SQs 49–53 sit ~1 km south of 31–43 and were not soil-sampled; presumably the peatland group with no voles — to confirm.
- Cross-check of his fixes against ours for 31–43, 49 shared corners: median offset 3.9 m, mean 5.3, 90th pct 11, max 25. Centroid offsets 1–6 m, mean shift ~1 m east and ~0 north, so no between-unit bias. His quadrat geometry is as irregular as ours, so the shape residuals are GPS noise. Per-fix error ~3–5 m, not 2. Protocol §2 updated with these numbers.
- Corner letters differ between observers: 34 B/D swapped, 37 rotated one corner. Our letters define the soil samples; his are used for centroids only.
- GPX input for `R/01_wp1_trap_grid_gpx.R` moved to `data-raw/wp1_finland/henttonen/` (ignored), per repository policy.
- Coordinates for 15 Sep entered (42 rows appended: LOM1/2, 8-10A/B, SQs 44–48 and 54–57, REF1/REF2 from one spot at 68.025485, 24.160570). 38–43 re-read from the unit and matched the file; 43 resolved as first-set A + second-set D, corrections table updated. 58A, 58D and 36 were not re-recorded: 58 stays at two corners, 36 at three. REF3 and REF4 not collected.
- All 25 forest SQs now have centroids. Single-linkage clustering: within-group merges 49–83 m, then 202 m, so four spatial groups at any cut in between: G31 (31–43, 13 SQ), G44 (44–48), G54 (54–57), G58 (58–60). G31 may be two design groups (31–37, 38–43) that abut; ask Heikki. Lines: 8-10 is 145 m from SQ 54, MS/MS+ 230–290 m from SQ 46, LOM ~2 km from any quadrat. Two-point spans: 8-10 17 m, LOM 28 m, MS 46 m, MS+ 64 m.
- Quadrats 44 and 48 come out large (sides 19–26 m, diagonals 30–33 m); left as recorded.
