# microbial_sensor

Using the rodent gut microbiome as a sensor of host social and environmental connectivity.

Birgitta Sintring Fellowship, [Videvall lab](PLACEHOLDER — lab URL), Department of Ecology and Genetics, Uppsala University. Sep 2026 – Aug 2028.

> **Status: pre-fieldwork.** No data have been collected. The repository currently holds protocol drafts, the preregistration skeleton, and the project skeleton for the analysis code. Protocols in `docs/protocols/` are the authoritative description of the design; the funded proposal in `docs/proposal/` is background only, and the design has changed since submission.

## Question

Individuals that interact, or that share the same physical spaces, exchange gut microbes. If that exchange leaves a readable signature, dyadic microbiome similarity can be used to infer connectivity between hosts — cheaply, from samples that wildlife monitoring programmes already collect, and without telemetry. This project asks whether that inference works, and whether the signal can be decomposed into a **social** channel (direct contact) and an **environmental** channel (shared nests, burrows, and soil), while accounting for host relatedness and spatial overlap.

The pathogen endpoint is Puumala orthohantavirus (PUUV), which is endemic to bank voles (*Clethrionomys glareolus*) and transmitted through both channels.

## Work packages

| | WP1 — Pallasjärvi | WP2 — Grimsö |
|---|---|---|
| **Site** | Pallasjärvi, Finnish Lapland | Grimsö Wildlife Research Station, Sweden |
| **When** | September 2026 | Summer 2027 (provisional — timing under review) |
| **Trapping** | Snap-trapping, 3–4 nights per grid | Live-trapping, CMR, 3 ha nested grid |
| **Samples** | Gut (distal colon) + paired nest/burrow and soil, ~150 individuals | Longitudinal faecal/rectal swabs, ~20–40 tracked individuals |
| **Connectivity** | Inferred from within-campaign spatial co-occurrence | Observed directly, via RFID proximity logging |
| **Collaborator** | Prof. Heikki Henttonen (Luke) | PLACEHOLDER — Grimsö/SLU contact |

WP1 fits the sensor model. WP2 validates it against an observed contact network: whether microbiome-inferred connectivity recovers the network that RFID actually measured.

Y1 = Sep 2026 – Aug 2027; Y2 = Sep 2027 – Aug 2028.

## Methods

- Full-length 16S rRNA amplicon sequencing (PacBio HiFi), giving single-nucleotide ASV resolution
- DADA2 for read processing and ASV inference
- Compositional data analysis for community similarity
- Bayesian hierarchical models of dyadic microbiome similarity, with social and environmental transmission as separate terms

## Analyses in this repository

Not everything here is under the same constraints.

**1. Sensor model — preregistered.** The primary analysis. The design and analysis plan will be publicly preregistered (OSF or equivalent) before the WP2 data exist; the plan lives in `docs/prereg/`. While it is named `prereg_DRAFT.qmd` it is not yet filed and is still being developed; on filing it is renamed to `prereg.qmd` and carries its filing date and registry link. Once filed, anything that would change analysis logic, model specification, or pipeline parameters is a documented deviation, not a code change. This analysis was previously planned as a Registered Report at *Nature Ecology & Evolution*; that submission has been dropped.

**2. Everything else — normal.** Exploratory work, secondary questions, methods development. Ordinary practice applies.

## Layout

```
docs/
  proposal/    funded proposal (background only — superseded in places)
  protocols/   field, lab, and data management protocols
  prereg/      preregistration drafts and the filed plan (Quarto → PDF/DOCX)
notes/         working notes
data-raw/      raw data — read-only, never committed
data/          processed data — directory tree tracked, contents ignored
R/             analysis scripts and functions
pipelines/     DADA2 / sequence processing
```

Analysis scripts are numbered by pipeline stage.

### Key documents

| File | What it is |
|---|---|
| `docs/prereg/prereg_DRAFT.qmd` | Preregistration of the design and analysis plan (draft, not filed) |
| `docs/protocols/pallasjarvi-fieldwork-protocol.qmd` | WP1 field collection |
| `docs/protocols/grimso-field-protocol.qmd` | WP2 trapping, RFID, sampling |
| `docs/protocols/pilot-lab-protocol.qmd` | Pilot extraction/QC before the preregistration locks |
| `docs/protocols/data-management-plan.qmd` | Sample IDs, metadata schema, batch design |
| `notes/microbiome_pipeline.qmd` | Wet-lab and bioinformatics workflow |

Several of these are drafts with explicitly marked placeholders.

## Getting started

Requires R 4.2.3 and [Quarto](https://quarto.org). Dependencies are managed with [`renv`](https://rstudio.github.io/renv/).

```r
# from the project root
renv::restore()   # install the package versions in renv.lock
```

Open `microbial_sensor.Rproj` in RStudio, or set the working directory to the project root — paths are resolved with `here::here()`, so nothing depends on where the project sits on disk.

Render a document with:

```bash
quarto render docs/prereg/prereg_DRAFT.qmd
```

Sequence processing is intended to run on UPPMAX rather than locally.

## Data

- `data-raw/` is **read-only** and is never committed. Nothing in the pipeline writes to it.
- `data/` keeps its directory tree under version control but not its contents; each subdirectory has a README describing what belongs there.
- Sequence data will be deposited in a public archive (PLACEHOLDER — ENA or SRA) and metadata in PLACEHOLDER — repository, with release timed to publication. See `docs/protocols/data-management-plan.qmd`.

## Ethics and permits

PLACEHOLDER — animal ethics approvals (Finnish and Swedish), trapping permits, and any biosafety approvals for PUUV-positive material.

## Reuse

Code and documentation are released under [CC0 1.0](LICENSE) (public domain dedication). Attribution is not required, but is appreciated.

## Contact

David Simons, Department of Ecology and Genetics, Uppsala University — PLACEHOLDER — institutional email.
