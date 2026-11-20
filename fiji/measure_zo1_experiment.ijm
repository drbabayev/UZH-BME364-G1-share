// BME364: measure_zo1_experiment.ijm  (ImageJ / Fiji macro language)
// Copyright (c) 2026 Huseyn Babayev and Can Zeyneloglu, University of Zurich. MIT License.
// ZO-1 per nuclear area in the real Group I images (raw_data/confocal_zo1_8bit, 13 November 2026).
// Output: results/zo1_experiment_fiji.csv in the course folder (two levels up from the images), one row
// per image. R/06_if_experiment.Rmd joins it to raw_data/confocal_zo1_8bit/image_metadata.csv and computes
//     ZO-1 per nuclear area = ZO1_Mean / (Nuclear_Area_pct / 100)
//
// For every image:
//   1. maximum projection of the 4 z-slices
//   2. ZO-1: mean of the whole field
//   3. DAPI: Li threshold -> fill holes = mask of the nuclei
//   4. Process > Binary > Watershed: touching nuclei are cut at the narrow neck between them
//   5. nuclear area = white pixels of the mask; nuclei = objects of at least MIN_SIZE um^2
// Run: Plugins > Macros > Run...  and choose the folder raw_data/confocal_zo1_8bit
// Headless: fiji --headless -batch fiji/measure_zo1_experiment.ijm /full/path/raw_data/confocal_zo1_8bit/

ZO1_CH  = 1;          // channel 1 is ZO-1 (Alexa 546)
DAPI_CH = 2;          // channel 2 is DAPI
MIN_SIZE = 15;        // um^2, smaller objects are not counted as nuclei

input = getArgument();
if (input == "") input = getDirectory("Choose the folder with the .tif images (raw_data/confocal_zo1_8bit)");
if (!endsWith(input, File.separator)) input = input + File.separator;
outdir = File.getParent(File.getParent(input)) + File.separator + "results" + File.separator;
if (!File.exists(outdir)) File.makeDirectory(outdir);
output = outdir + "zo1_experiment_fiji.csv";

files = getFileList(input);
setBatchMode(true);
run("Options...", "iterations=1 count=1 black");
csv = "Label,ZO1_Mean,Nuclear_Area_pct,Nuclei\n";     // saved with File.saveString, so it also runs headless
n = 0;

for (i = 0; i < files.length; i++) {
  if (!endsWith(files[i], ".tif")) continue;
  open(input + files[i]);
  title = getTitle();

  // 1. maximum projection, one image per channel
  run("Z Project...", "projection=[Max Intensity]");
  mip = getTitle();
  run("Split Channels");

  // 2. ZO-1 mean of the whole field
  selectWindow("C" + ZO1_CH + "-" + mip);
  getStatistics(area, zo1);

  // 3. DAPI mask: Li threshold, fill holes
  selectWindow("C" + DAPI_CH + "-" + mip);
  setAutoThreshold("Li dark");
  run("Convert to Mask");
  run("Fill Holes");

  // 4. binary watershed, touching nuclei are cut apart
  run("Watershed");

  // 5. nuclear area and number of nuclei
  getStatistics(area, maskMean);
  run("Analyze Particles...", "size=" + MIN_SIZE + "-Infinity clear");
  csv = csv + title + "," + d2s(zo1, 4) + "," + d2s(100 * maskMean / 255, 4) + "," + nResults + "\n";
  n++;
  run("Close All");
}

File.saveString(csv, output);
setBatchMode(false);
print("Done: " + n + " images measured -> " + output);
