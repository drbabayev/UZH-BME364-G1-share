# Raw data from the SIAF experiments

Two kinds of raw data from the Group I experiments.

- **Plate reader:** two read-outs, MTT (absorbance) and fluorescence, each measured on two 96-well
  plates, plate A and plate B. Every plate is given in three forms.
- **Confocal images:** ZO-1 and DAPI in Caco-2 monolayers, 18 z-stacks as 8-bit TIFF files, with a
  table that says what each image is (see [Confocal images](#confocal-images) below).

```
raw_data/
├── instrument/                 files exactly as the plate reader wrote them, renamed only
│   ├── mtt_plateA.txt, mtt_plateA.dat
│   ├── mtt_plateB.txt, mtt_plateB.dat
│   ├── fluorescence_plateA.txt, fluorescence_plateA.dat
│   └── fluorescence_plateB.txt, fluorescence_plateB.dat
├── matrix/                     one plate per file, as a grid (rows A to H, columns 1 to 12)
│   ├── mtt_plateA.csv, mtt_plateB.csv
│   └── fluorescence_plateA.csv, fluorescence_plateB.csv
├── long/                       one plate per file, one row per well (tidy, tibble style)
│   ├── mtt_plateA.csv, mtt_plateB.csv                    columns plate, well, row, column, od
│   └── fluorescence_plateA.csv, fluorescence_plateB.csv  columns plate, well, row, column, rfu
├── make_tables.py              writes matrix/ and long/ from instrument/
└── confocal_zo1_8bit/          18 confocal z-stacks (8-bit TIFF), image_metadata.csv, scaling_8bit.csv
```

The values in `matrix/` and `long/` are the same numbers as in `instrument/`, copied without rounding.
`od` is the absorbance (optical density) and `rfu` the fluorescence in relative fluorescence units.

## Import in R

```r
# Long form, one row per well (best for dplyr and ggplot2)
library(readr)
mtt_a <- read_csv("raw_data/long/mtt_plateA.csv")
mtt_b <- read_csv("raw_data/long/mtt_plateB.csv")
mtt   <- dplyr::bind_rows(mtt_a, mtt_b)      # both plates together, told apart by the plate column

# Matrix form, one plate as an 8 x 12 matrix (rows A to H, columns 1 to 12)
plate_a <- as.matrix(read.csv("raw_data/matrix/mtt_plateA.csv", row.names = 1, check.names = FALSE))
plate_a["B", "2"]          # the value in well B2
```

To add the plate layout, make a table with the columns `plate`, `well` and what each well contains (for
example `condition`, `standard_ug_ml`, `blank`), and join it to the long table by `plate` and `well`.

## Original file names

| Original name on the plate reader | Renamed to |
|---|---|
| `bme36426group1p1mtt_hb.TXT`, `.dat` | `instrument/mtt_plateA.txt`, `.dat` |
| `bme36426group1p2mtt_hb.TXT`, `.dat` | `instrument/mtt_plateB.txt`, `.dat` |
| `bme36426group1p1_hb.TXT`, `.dat` | `instrument/fluorescence_plateA.txt`, `.dat` |
| `bme36426group1p2_hb.TXT`, `.dat` | `instrument/fluorescence_plateB.txt`, `.dat` |

`p1` in the original names is plate A and `p2` is plate B. The files were only renamed, and their
contents are unchanged.

## The instrument files

- The `.txt` file is the text export of one plate, 8 lines (rows A to H) of 12 tab-separated values
  (columns 1 to 12), without well labels and with Windows line endings.
- The `.dat` file is the binary file of the plate reader with the same read.
- The plate reader's clock was wrong, so the files are dated 2011. They were measured at SIAF in
  November 2026.

## Confocal images

`confocal_zo1_8bit/` holds the images taken on 13 November 2026. Rows of the 24-well glass-bottom
plate are conditions, columns are wells, and each well has 2 images.

| Row | Condition | Wells | Images |
|---|---|---|---|
| A | Control (medium only) | A1, A2, A3 | 6 |
| B | P80 0.02 % | B1, B2, B3 | 6 |
| C | P80 0.1 % | C1, C2, C3 | 6 |

- **File names:** well, condition and image number, for example `B2_P80_002_1.tif` is well B2,
  P80 0.02 %, image 1. `P80_002` means 0.02 % and `P80_01` means 0.1 %.
- **Each file** is an ImageJ hyperstack of 1024 × 1024 pixels with 2 channels and 4 z-slices,
  3 µm apart. The pixel size is 0.474 µm (2.108 pixels per µm).
- **Channel order:** channel 1 is ZO-1 (Alexa 546) and channel 2 is DAPI. The Fiji macro
  `fiji/measure_zo1.ijm` expects the opposite (C1 DAPI, C2 ZO-1), so swap the channels in the
  macro before you run it on these images.
- **8-bit conversion:** the microscope images are 16-bit. They were converted to 8-bit with the same
  linear scale for every image, as given in `scaling_8bit.csv`, so intensities can be compared
  between images. The 16-bit originals (1 GB) are not in the repository. They are on
  OneDrive in `Class Materials/Group1_IF_raw_files/16bit`.
- **`image_metadata.csv`** has the same columns as `data/image_metadata.csv`
  (`file`, `plate_well`, `condition`, `p80_pct`, `well`, `field`), so `R/05_if_analysis.Rmd` can join
  it to the Fiji results by file name.

```r
library(readr)
metadata <- read_csv("raw_data/confocal_zo1_8bit/image_metadata.csv")
```

## Why these files are in git

The plate reader files are small (336 KB) and the 8-bit images are 96 MB in total (about 6 MB per
file), so they are kept in git as the course's teaching data. This is a deliberate exception to the
rule that raw instrument exports stay out of the repository.
