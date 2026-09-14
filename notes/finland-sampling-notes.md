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
- `line_id` column added to all three tables. **Add it to `data-raw/wp1_finland/wp1_corner_coords.csv` by hand**, after `sq_id`, since that file was copied before the change.
