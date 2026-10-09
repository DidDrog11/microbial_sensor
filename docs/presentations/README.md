# presentations

Slide decks, written in Quarto Reveal.js (`format: revealjs`). The folder is gitignored apart from this file: decks are informal, may show preliminary results or material received from collaborators, and this repository is public. Keep the sources backed up outside git (Drive) if they matter.

| Deck | Occasion |
|---|---|
| `lab-meeting-videvall.qmd` | Videvall lab meeting, 2 October 2026: the project and the Pallasjärvi campaign |
| `frauke-ecke-chat.qmd` | Conversation with Frauke Ecke (SLU, national small-rodent monitoring), 9 October 2026: the science, the case for the monitoring series, a hantavirus extension. Notes in `notes/frauke-ecke-2026-10-09.qmd` |

`theme.scss` is the shared slide theme.

Render with `quarto render <deck>.qmd`; open the `.html` in a browser, `f` for full screen, `s` for speaker notes, `e` to print to PDF via the browser. Figures are read from `output/figures/` and tables from `data/` with `here::here()`, so re-run the numbered scripts in `R/` first if those are stale.
