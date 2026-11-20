#!/usr/bin/env python3
"""Write the plate reader text exports in instrument/ as tables that R reads directly.

    matrix/<assay>_plate<A|B>.csv   the 96-well plate as a grid, rows A to H, columns 1 to 12
    long/<assay>_plate<A|B>.csv     the same plate with one row per well (tidy, tibble style)

Values are copied as text, exactly as the plate reader wrote them (no rounding). Run from anywhere:
    python3 raw_data/make_tables.py
"""
import csv
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROWS = "ABCDEFGH"
COLS = range(1, 13)
ASSAYS = {"mtt": "od", "fluorescence": "rfu"}      # assay -> name of the value column
PLATES = "AB"


def read_plate(path):
    """The 8 x 12 grid of one .txt export (tab separated, Windows line endings, empty lines at the end)."""
    lines = [l for l in path.read_text(encoding="ascii").splitlines() if l.strip()]
    grid = [l.split() for l in lines]
    assert len(grid) == 8 and all(len(r) == 12 for r in grid), f"{path.name} is not an 8 x 12 plate"
    for r in grid:
        for v in r:
            float(v)                                   # every cell must be a number
    return grid


def main():
    (HERE / "matrix").mkdir(exist_ok=True)
    (HERE / "long").mkdir(exist_ok=True)
    for assay, value in ASSAYS.items():
        for plate in PLATES:
            grid = read_plate(HERE / "instrument" / f"{assay}_plate{plate}.txt")
            with open(HERE / "matrix" / f"{assay}_plate{plate}.csv", "w", newline="") as f:
                w = csv.writer(f, lineterminator="\n")
                w.writerow(["row", *COLS])
                for r, vals in zip(ROWS, grid):
                    w.writerow([r, *vals])
            with open(HERE / "long" / f"{assay}_plate{plate}.csv", "w", newline="") as f:
                w = csv.writer(f, lineterminator="\n")
                w.writerow(["plate", "well", "row", "column", value])
                for r, vals in zip(ROWS, grid):
                    for c, v in zip(COLS, vals):
                        w.writerow([plate, f"{r}{c}", r, c, v])
            print(f"{assay} plate {plate}: matrix and long table (96 wells)")


if __name__ == "__main__":
    main()
