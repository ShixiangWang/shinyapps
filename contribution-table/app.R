library(shiny)
library(rhandsontable)
library(shinyjs)
library(DataEditR)
library(contribution)

reset_data <- as.data.frame(matrix(rep("", 100), ncol = 10))

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
      tags$p(
        "The first column show the role and the other columns show the people or projects.",
        markdown("Read [CRediT](https://casrai.org/credit/) for contributor roles taxonomy.")
      ),
      tags$p(
        "For a 3-level contribution table, only 'Minor' and 'Major' are valid, a void cell for no contribution.",
        markdown("Please report any suggestion/bug at [here](https://github.com/ShixiangWang/shinyapps/issues).")
      )
    )
  ),
  useShinyjs(),
  fluidRow(
    column(
      width = 6,
      dataInputUI("input1"),
      actionButton("load", label = "Update upload file", icon = icon("mouse")),
      rHandsontableOutput("data1"),
      tags$br(),
      div(
        style = "display:inline-block;width:50%;text-align: center;",
        actionButton("example", label = "Example data", icon = icon("table")),
        actionButton("clear", label = "Clear table", icon = icon("broom")),
        actionButton("run", label = "Plot", icon = icon("paper-plane"))
      )
    ),
    column(
      width = 6,
      plotOutput("contribution")
    )
  ),
  tags$br(),
  HTML("<p style=\"text-align:center\">&copy; 2020 <a href=\"https://shixiangwang.github.io/home/\">Shixiang Wang<a/><p></p>")
)

server <- function(input,
                   output,
                   session) {
  data_input1 <- dataInputServer("input1")

  # Bug: 如果已经有数据，加载文件无法自动显示
  output$data1 <- renderRHandsontable({
    if (!is.null(data_input1())) {
      rhandsontable(data_input1())
    }
  })

  observeEvent(input$load, {
    output$data1 <- renderRHandsontable({
      if (!is.null(data_input1())) {
        rhandsontable(data_input1())
      }
    })
  })

  observeEvent(input$example, {
    output$data1 <- renderRHandsontable({
      rhandsontable(contribution::demo)
    })
  })

  observeEvent(input$clear, {
    output$data1 <- renderRHandsontable({
      rhandsontable(reset_data)
    })
  })

  DF <- reactive({
    hot_to_r(input$data1)
  })
  observeEvent(input$run, {
    if (any(DF() != "")) {
      output$contribution <- renderPlot({
        contribution::generate(isolate(DF()))
      })
    }
  })
}

shinyApp(ui, server)
