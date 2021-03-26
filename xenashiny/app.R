#library(UCSCXenaShiny)
#app_run("server")

options(xena.runMode = "server")
shiny::shinyAppFile(system.file("shinyapp", "App.R", package = "UCSCXenaShiny"))