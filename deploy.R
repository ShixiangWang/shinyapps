library(rsconnect)

rsconnect::deployApp(
  'xenashiny',
  appName = "ucscxenashiny", appTitle = "UCSCXena Shiny demo")


rsconnect::deployApp(
  'contribution-table',
  appName = "contribution", appTitle = "Contribution Table Shiny demo")
