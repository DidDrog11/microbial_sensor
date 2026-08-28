# microbial_sensor

## Project

Fellowship project (Birgitta Sintring Fellowship, Videvall lab, Dept. of Ecology and Genetics, Uppsala University) using the rodent gut microbiome as a sensor of host social and environmental connectivity. Sep 2026 – Aug 2028.    

- **Y1** = Sep 2026 – Aug 2027
- **Y2** = Sep 2027 – Aug 2028

### Field components

- **WP1** — Bank voles (*Myodes glareolus*), Pallasjärvi, Finnish Lapland. Snap-trapped September 2026 (Y1) with Prof. Heikki Henttonen (Luke). ~150 individuals. Gut tissue (distal colon) plus paired nest/burrow and soil samples. Puumala orthohantavirus (PUUV) is the pathogen endpoint.
- **WP2** — Bank voles, Grimsö, Sweden. Live-trapping with RFID tracking,  autumn of Y2. Longitudinal; validates the WP1 model against an observed contact network.

Methods: full-length 16S rRNA amplicon sequencing (PacBio HiFi) + DADA2; compositional data analysis; Bayesian hierarchical models for dyadic microbiome similarity, decomposing social vs. environmental transmission channels.

The funded proposal is in `docs/proposal/`. Useful for background and rationale, but **it is not the current plan** — the design has already changed since submission. Where the two disagree, the protocols in `docs/protocols/` are authoritative.

## Analyses

The fellowship supports more than one analysis. Constraints differ by analysis, so check which one a task belongs to before assuming what applies.

### 1. Sensor model (Registered Report) — CONSTRAINED

The primary analysis, submitted to *Nature Ecology & Evolution* as a Registered Report. The Stage 1 protocol fixes the sampling design, bioinformatic pipeline, and statistical model specification in advance; Stage 2 is evaluated on whether that protocol was followed.

For anything under this analysis:

- **Do not change analysis logic, model specification, or pipeline parameters on your own initiative.** If something looks wrong,  suboptimal, or inconsistent with best practice, say so and stop — do not fix it. A deviation from the pre-registered protocol is a scientific problem, not a code problem, and has to be a deliberate,
  documented decision.
- **Do not expand scope.** If a task reveals adjacent work that seems worth doing, name it and wait.

Once Stage 1 is submitted, `docs/protocols/` records what was pre-registered. Treat those documents as fixed.

### 2. Other analyses — NORMAL

Exploratory work, secondary questions, side analyses, methods development. Ordinary practice applies: suggest improvements, flag problems, propose better approaches.

If it is not clear which category a task falls in, ask.

## Roles

Claude Code is used here for infrastructure and implementation: repo structure, pipeline scripts, QC, data management, documentation, refactoring, debugging.

Statistical model specification, the operational definition of connectivity, and interpretive decisions for the Registered Report are developed separately and arrive here already decided. Implement what is specified; do not originate it.

## Attribution

Do not add Claude, Anthropic, or any AI tool as a co-author, committer, or contributor. No `Co-Authored-By` trailers, no "Generated with" footers, no attribution comments in code or documentation.

This is about scope, not concealment: AI use is disclosed at the level of research outputs, by the author, according to current publishing norms — not embedded in commit metadata.

## Conventions

- R, with `renv` for dependency management
- Quarto (`.qmd`) for protocols, notebooks, and documentation
- Analysis scripts numbered by pipeline stage
- `data-raw/` is read-only — never write to it
- No absolute paths — use `here::here()`

## Git

- Commit messages: imperative mood, plain description of what changed
- Do not commit unless asked
- Never commit contents of `data-raw/`, large data files, or credentials
- Do not force-push, rewrite history, or amend published commits

## Layout

```
docs/
  proposal/    funded proposal (background only — see note above)
  protocols/   field, lab, and data management protocols
  rr/          Registered Report manuscript drafts
notes/         working notes
data-raw/      raw data, read-only
data/          processed data
R/             analysis scripts and functions
pipelines/     DADA2 / sequence processing
```

Subdirectory `CLAUDE.md` files add local conventions.