# registry

Identifier registries: derived once by a script, then frozen and **tracked in git**, unlike the rest of `data/`. A registry is append-only. Scripts that maintain one read it first, keep every existing row unchanged, and add rows for new items after the current maximum. If a registry ever needs correcting, the change is made deliberately and described in the commit, never by regenerating the file.

| File | Maintained by | Content |
|---|---|---|
| `wp1_sample_codes.csv` | `R/05_wp1_notebook_animals.R` | one row per animal in Henttonen's notebook: `animal_id` (date + his within-day number, e.g. `20260913-05`), project `sample_code` (`P-NNN`, chronological, all species), the notebook location and species code as transcribed, and the date the code was assigned. Gut sample IDs are `P-NNN-C` (caecum) and `P-NNN-D` (distal colon); a bag holding both organs is `P-NNN` alone |
