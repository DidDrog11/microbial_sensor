# microbial_sensor

## Project

Fellowship project (Birgitta Sintring Fellowship, Videvall lab, Dept. of Ecology and Genetics, Uppsala University) using the rodent gut microbiome as a sensor of host social and environmental connectivity. Sep 2026 – Aug 2028.    

- **Y1** = Sep 2026 – Aug 2027
- **Y2** = Sep 2027 – Aug 2028

### Field components

- **WP1** — Bank voles (*Clethrionomys glareolus*), Pallasjärvi, Finnish Lapland. Snap-trapped 12–17 September 2026 with Prof. Heikki Henttonen (LUKE), on his existing long-term monitoring design (30 small quadrats of 15 × 15 m, in groups of 3–7, ≥50 m apart within a group; forest and peatland groups; two trap-nights per session). ~150 individuals. Caecum and distal colon in separate bags, plus opportunistic nest/burrow material, paired soil at capture points, off-grid reference soil, and field blanks. Puumala orthohantavirus (PUUV) is the pathogen endpoint.
- **WP2** — Bank voles, Grimsö, Sweden. Live-trapping with RFID logging and repeated faecal swabs, four sessions May–August 2027. Longitudinal; validates the WP1 model against an observed association network. Requires a Swedish animal ethics permit (not yet applied for) and RFID hardware that is not currently in the budget.

Methods: full-length 16S rRNA amplicon sequencing (PacBio HiFi, NGI Stockholm) + DADA2; compositional data analysis; Bayesian hierarchical models for dyadic microbiome similarity, decomposing social vs. environmental transmission channels.

The funded proposal is in `docs/proposal/`. Useful for background and rationale, but **it is not the current plan** — the design has changed since submission. Where the two disagree, the protocols in `docs/protocols/` are authoritative.

Known divergences from the funded proposal, for reference: the Swedish national monitoring archive has been dropped from WP1 (funding, and circularity with WP2); WP1 samples are prospectively collected rather than archived; host genotyping for the kinship term is currently unfunded and may be dropped, though tissue will be retained for it.

## Analyses

The fellowship supports more than one analysis. Constraints differ by analysis, so check which one a task belongs to before assuming what applies.

### 1. Sensor model — PREREGISTERED, CONSTRAINED AFTER FILING

The primary analysis. **This is no longer a Registered Report.** The Stage 1 submission to *Nature Ecology & Evolution* has been dropped: too many open design questions to fix a protocol and decision rules in advance, and the funded WP2 design is not powered for the out-of-sample validation an RR would have committed to.

In its place, the design and analysis plan will be publicly preregistered (OSF or equivalent) before the WP2 data exist. The scientific intent is unchanged; what changes is that the plan is not under journal review and can still be revised while it is being written.

This means the constraint is now time-dependent:

- **Before the preregistration is filed:** ordinary practice applies. Flag problems, suggest improvements, propose better approaches. The plan is still being developed.
- **After the preregistration is filed:** treat the filed plan as fixed. Do not change analysis logic, model specification, or pipeline parameters on your own initiative. If something looks wrong, suboptimal, or inconsistent with best practice, say so and stop — do not fix it. A deviation from the preregistered plan is a scientific decision that has to be made deliberately and documented, not a code problem.

The preregistration lives in `docs/prereg/`. While it is named `prereg_DRAFT.qmd` the plan is not yet filed and ordinary practice applies. On filing it is renamed to `prereg.qmd`, and the filing date and registry link are recorded at the top of the document.

### 2. Other analyses — NORMAL

Exploratory work, secondary questions, side analyses, methods development. Ordinary practice applies.

If it is not clear which category a task falls in, ask.

## Roles

Claude Code is used here for infrastructure and implementation: repo structure, pipeline scripts, QC, data management, documentation, refactoring, debugging.

Statistical model specification, the operational definition of connectivity, and interpretive decisions are developed separately and arrive here already decided. Implement what is specified; do not originate it.

## Attribution

Do not add Claude, Anthropic, or any AI tool as a co-author, committer, or contributor. No `Co-Authored-By` trailers, no "Generated with" footers, no attribution comments in code or documentation.

This is about scope, not concealment: AI use is disclosed at the level of research outputs, by the author, according to current publishing norms — not embedded in commit metadata.

## Conventions

- R, with `renv` for dependency management
- Quarto (`.qmd`) for protocols, notebooks, and documentation
- Analysis scripts numbered by pipeline stage
- `data-raw/` is read-only — never write to it
- No absolute paths — use `here::here()`
- Spatial work uses `terra` and `tidyterra`, not `sf`. Rasters and vectors both go through terra; tidyterra supplies the dplyr verbs for `SpatVector` and `SpatRaster`.
- Do not hard-wrap prose at a fixed column. Write each paragraph, list item, or table row as one line and let the editor soft-wrap it. This applies to Markdown, Quarto, and commit message bodies; code still follows normal line-length conventions.

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
  prereg/      preregistration drafts and the filed plan
notes/         working notes
data-raw/      raw data, read-only
data/          processed data
R/             analysis scripts and functions
pipelines/     DADA2 / sequence processing
```

Subdirectory `CLAUDE.md` files add local conventions.