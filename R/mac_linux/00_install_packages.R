# BME364 Group I: install the R packages once (macOS and Linux).
# Run in RStudio: open this file and click Source.
# Linux (Debian/Ubuntu) needs these system libraries first, in a terminal:
#   sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev \
#     libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
install.packages(c("rmarkdown", "tidyverse", "rstatix", "lme4", "lmerTest", "emmeans", "drc"))
