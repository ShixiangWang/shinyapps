library(shiny)
library(rhandsontable)
library(shinyjs)
library(DataEditR)
library(contribution)

ui <- fluidPage(
  theme = "style.css",
  # Title
  tags$div(
    id = "titleBar",
    tags$div(
      id = "container",
      tags$h1("Tiny Contribution Table Generator")
    )
  ),
  # Intro
  tags$div(
    id = "outer-content",
    tags$div(
      id = "intro",
      tags$p("The first column show the role and the other columns show the people or projects.",
             markdown("Read [CRediT](https://casrai.org/credit/) for contributor roles taxonomy.")),
      tags$p("For a 3-level contribution table, only 'Minor' and 'Major' are valid, a 'NA' value should put in cell for no contribution.",
             markdown("Please report any suggestion/bug at [here](https://github.com/ShixiangWang/shinyapps/issues)."))
    )
  ),
  useShinyjs(),
  dataInputUI("input1"),
  #dataOutputUI("output1"),
  rHandsontableOutput("data1"),
  div(style="display:inline-block;width:50%;text-align: center;",
      actionButton("example", label = "Example data", icon = icon("table")),
      actionButton("clear", label = "Clear table", icon = icon("broom")),
      actionButton("run", label = "Plot", icon = icon("paper-plane"))),
  plotOutput("contribution"),
  tags$br(),
  HTML("<p style=\"text-align:center\">&copy; 2020 <a href=\"https://shixiangwang.github.io/home/\">Shixiang Wang<a/><p></p>")
)

server <- function(input,
                   output,
                   session) {
  data_input1 <- dataInputServer("input1")

  output$data1 <- renderRHandsontable({
    if (!is.null(data_input1())) {
      rhandsontable(data_input1())
    }
  })

  observeEvent(input$example, {
    output$data1 <- renderRHandsontable({
      rhandsontable(contribution::demo)
    })
  })

  observeEvent(input$clear, {
    output$data1 <- renderRHandsontable({
      rhandsontable(data_input1())
    })
  })

  # dataOutputServer("output1",
  #   data = data_input1
  # )

  observeEvent(input$run, {
    output$contribution <- renderPlot({
      contribution::generate(output$data1)
    })
  })
}

shinyApp(ui, server)
