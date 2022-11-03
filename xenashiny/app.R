#!/usr/bin/env Rscript
# Copyright (C) 2021 Xena Shiny Team

# The cache directory and port all should be consistent with
# configs in Dockerfile.

# Check system info
print(Sys.info())

# Set options and preloading -------------------------------------

options(xena.cacheDir = "~/.xenashiny", xena.zenodoDir = "~/.xenashiny/datasets")
options(xena.runMode = "server")

library(UCSCXenaShiny)

tryCatch({
  # Preload datasets
  load_data("transcript_identifier")
  load_data("tcga_TIL")
  invisible(NULL)
}, error = function(e) {
  warning("Preload data failed due to the network, it will try again when starting Shiny!")
})

# Global setting ---------------------------------------------------------
xena.runMode <- getOption("xena.runMode", default = "client")
message("Run mode: ", xena.runMode)

if (is.null(getOption("xena.cacheDir"))) {
  options(xena.cacheDir = switch(xena.runMode,
                                 client = file.path(tempdir(), "UCSCXenaShiny"),
                                 server = "~/.xenashiny"
  ))
}

# Path for storing dataset files
XENA_DEST <- path.expand(file.path(getOption("xena.cacheDir"), "datasets"))

if (!dir.exists(XENA_DEST)) {
  dir.create(XENA_DEST, recursive = TRUE)
}

# Set default path for saving extra-data downloaded from https://zenodo.org
if (xena.runMode == "server") {
  if (is.null(getOption("xena.zenodoDir"))) options(xena.zenodoDir = XENA_DEST)
}

# Load necessary packages ----------------------------------
message("Checking depedencies...")

if (!requireNamespace("pacman")) {
  install.packages("pacman", repos = "http://cran.r-project.org")
}
library(pacman)

if (!requireNamespace("gganatogram")) {
  pacman::p_load(remotes)
  tryCatch(
    remotes::install_github("jespermaag/gganatogram"),
    error = function(e) {
      remotes::install_git("https://gitee.com/XenaShiny/gganatogram")
    }
  )
}

if (!requireNamespace("ggradar")) {
  pacman::p_load(remotes)
  tryCatch(
    remotes::install_github("ricardo-bion/ggradar"),
    error = function(e) {
      remotes::install_git("https://gitee.com/XenaShiny/ggradar")
    }
  )
}

if (packageVersion("UCSCXenaTools") < "1.4.4") {
  tryCatch(
    install.packages("UCSCXenaTools", repos = "http://cran.r-project.org"),
    error = function(e) {
      warning("UCSCXenaTools <1.4.4, this shiny has a known issue (the download button cannot be used) to work with it. Please upate this package!",
              immediate. = TRUE
      )
    }
  )
}

pacman::p_load(
  purrr,
  tidyr,
  stringr,
  magrittr,
  R.utils,
  data.table,
  dplyr,
  ggplot2,
  cowplot,
  ggpubr,
  plotly,
  UCSCXenaTools,
  UCSCXenaShiny,
  shiny,
  shinyBS,
  shinyjs,
  shinyWidgets,
  shinyalert,
  shinyFiles,
  shinythemes,
  survival,
  survminer,
  ezcox,
  waiter,
  colourpicker,
  DT,
  fs,
  RColorBrewer,
  gganatogram,
  ggcorrplot,
  ggstatsplot,
  ggradar,
  zip
)

options(shiny.maxRequestSize=1024*1024^2)


# Run app -----------------------------------------------------------------

shiny::shinyAppFile(
  system.file("shinyapp", "App.R", package = "UCSCXenaShiny")
)
