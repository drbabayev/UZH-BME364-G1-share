# BME364 Group I: tight junctions and barrier measurements

Materials for the two Group I workshops on 5 November 2026 (Huseyn Babayev, Can Zeyneloglu).

| Folder | Contents |
|---|---|
| `slides/` | PDFs of Confocal Part II (ZO-1 in Fiji and R) and Epithelial barrier measurements (statistics, MTT, TEER, FITC-dextran flux) |
| `manuals/` | Lab protocols (PDF): ZO-1 immunofluorescence, TEER, FITC-dextran flux, MTT; and the Davos lab schedule, hour by hour (`BME364_Group_I_schedule.pdf`) |
| `fiji/measure_zo1.ijm` | Batch macro: z-projection → DAPI mean, ZO-1 mean |
| `example_images/` | 4 real confocal fields (.tif) to practise Fiji on; see its README |
| `R/mac_linux/`, `R/windows/` | One R Markdown file (.Rmd) per read-out, for your operating system |
| `data/` | Example data in the same format as your own data |

> The example data in `data/` are **simulated**. They show the file format and the analysis; they
> are not experimental results. The images in `example_images/` are real.

## Design

Caco-2 monolayers, **control and polysorbate 80 (P80) 0.02, 0.1 and 0.5 % v/v** for TEER and
FITC-dextran flux (inserts in a 24-well Transwell plate) and ZO-1 immunofluorescence (24-well
glass-bottom plate, 4 wells per condition, 5 fields per well). MTT over a P80 dose series from 1 % down to 0.03125 % (2-fold), with control
columns on both sides of the series. One experiment, so n = wells or inserts (technical replicates).
Each P80 concentration vs control: ANOVA + Dunnett (Games–Howell when SDs differ); MTT also an IC50
fit. ZO-1 amount is reported as the ZO-1/DAPI ratio.

## Run the analyses

R ≥ 4.3 and RStudio. Use the folder for your computer: **`R/mac_linux/`** on macOS and Linux,
**`R/windows/`** on Windows. Both hold the same analyses; the Windows files have Windows line
endings and only ASCII characters in the code.

Install the packages once: open `00_install_packages.R` from your folder in RStudio and click
**Source** (it installs `rmarkdown`, `tidyverse`, `rstatix`, `lme4`, `lmerTest`, `emmeans` and `drc`;
on Linux, first install the system libraries listed at the top of the file).

Keep the folder structure as it is. Open an `.Rmd` file from your folder in RStudio and click **Knit**: you
get an HTML report with every step, test and plot next to the file, and the plot is also saved to
`figures/`. You can also run the chunks one by one with the green arrows. Knit `03_teer.Rmd`
before `04_flux.Rmd`: the flux file reads `results/teer_per_insert.csv`.

To analyse your own data, replace the file in `data/` with your measurements in the same columns.

| Read-out | Script | Data |
|---|---|---|
| Statistics | `01_statistics.Rmd` | `data/stats_example.csv` |
| MTT | `02_mtt.Rmd` | `data/mtt_raw.csv` |
| TEER | `03_teer.Rmd` | `data/teer_raw.csv` |
| FITC-dextran flux | `04_flux.Rmd` | `data/flux_standards.csv`, `data/flux_samples.csv` |
| ZO-1 | `fiji/measure_zo1.ijm`, then `05_if_analysis.Rmd` | `data/fiji_results_zo1.csv`, `data/image_metadata.csv` |

The scripts are in `R/mac_linux/` or `R/windows/`.

## License

© 2026 Huseyn Babayev and Can Zeyneloglu, University of Zurich. Slides, manuals, example images and
data: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); code (R Markdown, Fiji macro):
MIT. Reuse is welcome with attribution; see `LICENSE.md` for how to cite and for the third-party
parts (UZH logo and design, title photos, the published figures) that keep their own licenses.
