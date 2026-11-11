# Example images to practise on

Four real confocal fields of Caco-2 monolayers from an earlier P80 experiment, one per condition.
`image_metadata.csv` says which image is which:

| File | Condition |
|---|---|
| `if_001.tif` | control (medium) |
| `if_002.tif` | P80 0.01 % |
| `if_003.tif` | P80 0.1 % |
| `if_004.tif` | P80 0.5 % |

**Format.** ImageJ TIFF with 3 channels and one plane (already maximum projections):
C1 = DAPI (blue), C2 = green, C3 = red. These cells were stained for **occludin and claudin-1**
(one green, one red), not ZO-1. The values are 8-bit as exported from the microscope software, with
its display settings applied, and the files carry no pixel size.

**Open** a file in Fiji by dragging it onto the Fiji window. *Image › Color › Channels Tool* switches
between the channels and the composite.

**Practise** the steps from the slides: split the channels, measure DAPI on C1 and the junction stain
on C2, both on the whole field, raw. `fiji/measure_zo1.ijm` runs on this
folder: it reads C1 as DAPI and C2 as the junction stain (written to the `ZO1_Mean` column).

**Limits.** One field per condition, so these images are for practice, not
for statistics. Your own images from Davos are 16-bit, 2-channel TIFF z-stacks (C1 = DAPI, C2 = ZO-1).
