// BME364: measure_zo1.ijm  (ImageJ / Fiji macro language)
// Copyright (c) 2026 Huseyn Babayev and Can Zeyneloglu, University of Zurich. MIT License.
// ZO-1 tight-junction read-outs per confocal field: C1 = DAPI, C2 = ZO-1 (Alexa 546).
// File names can be anything (e.g. as exported by the microscope); the Label column only
// identifies the image. What each image is (plate well, condition, field, antibody) goes in a
// separate metadata table, image_metadata.csv, joined to the results in R/05_if_analysis.Rmd.
// Output: results.csv in the input folder, one row per image.
//
// Algorithm, for every field:
//   1. z-stack -> maximum-intensity projection (skipped for single planes); split channels
//   2. DAPI: raw mean of the whole field (nuclear DNA ~ number of cells); no background
//      subtraction: in a confluent monolayer a rolling ball cuts into the nuclei themselves
//   3. ZO-1: raw mean of the whole field (never rescale or auto-adjust before measuring);
//      R computes the ZO-1/DAPI ratio = ZO-1 mean / DAPI mean
// The same parameters are applied to every image: that is the point of the macro.
// Check on a few control and P80 images that neither DAPI nor ZO-1 is saturated before a batch run.
// Run: Plugins > Macros > Run...  (or open in the script editor and press Run)

input = getArgument();   // folder can be passed on the command line (headless runs)
if (input == "") input = getDirectory("Choose the folder with the .tif images");
if (!endsWith(input, File.separator)) input = input + File.separator;
files = getFileList(input);

setBatchMode(true);
Table.create("ZO1");
row = 0;

for (i = 0; i < files.length; i++) {
  if (!endsWith(files[i], ".tif")) continue;
  open(input + files[i]);
  title = getTitle();

  // 1. project the z-stack, split channels
  getDimensions(w, h, channels, slices, frames);
  if (slices > 1) {
    run("Z Project...", "projection=[Max Intensity]");
    selectWindow(title);
    close();
    selectWindow("MAX_" + title);
  }
  img = getTitle();
  run("Split Channels");

  // 2. DAPI: raw mean of the whole field (no selection)
  selectWindow("C1-" + img);
  getStatistics(area, dapi);

  // 3. ZO-1: raw mean of the whole field
  selectWindow("C2-" + img);
  getStatistics(area, zo1);

  Table.set("Label", row, title, "ZO1");
  Table.set("DAPI_Mean", row, d2s(dapi, 1), "ZO1");
  Table.set("ZO1_Mean", row, d2s(zo1, 1), "ZO1");
  row++;
  run("Close All");
}

selectWindow("ZO1");
Table.save(input + "results.csv");
setBatchMode(false);
print("Done: " + row + " fields measured -> " + input + "results.csv");
