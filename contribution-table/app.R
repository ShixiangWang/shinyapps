library(shiny)
library(rhandsontable)
library(shinyjs)
library(DataEditR)
library(contribution)

reset_data <- as.data.frame(matrix(rep("", 49), ncol = 7))

move_colname_to_row <- function(df) {
  rbind(colnames(df), df)
}

move_row_to_colname <- function(df) {
  colheader <- df[1, ]
  df <- df[-1, ]
  colnames(df) <- colheader
  df
}

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
      markdown(
        "This tool generates simple contribution table for credit assignment in a project.\
      The first column show the role and the other columns show the people or projects. Read [CRediT](https://casrai.org/credit/) for contributor roles taxonomy.

      - For a 3-level contribution table, only 'Minor' and 'Major' are valid, a void cell for no contribution.
      - Please report any suggestion/bug at [here](https://github.com/ShixiangWang/shinyapps/issues). If you are familiar with R, [contribution](https://github.com/openbiox/contribution) package provides more features.\
      "
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
        actionButton("run", label = "Plot", icon = icon("paper-plane")),
        downloadButton("downloadplot", label = "Save PDF", icon = icon("download")),
      )
    ),
    column(
      width = 6,
      plotOutput("contribution")
    )
  ),
  tags$br(),
  HTML("<p style=\"text-align:center\">&copy; 2020 <a href=\"https://shixiangwang.github.io/home/\">Shixiang Wang</a><p></p>")
)

server <- function(input,
                   output,
                   session) {
  data_input1 <- dataInputServer("input1", data = c(7, 7))

  # Bug: 如果已经有数据，加载文件无法自动显示
  output$data1 <- renderRHandsontable({
    if (!is.null(data_input1())) {
      rhandsontable(move_colname_to_row(data_input1()),
        colHeaders = NULL, useTypes = FALSE,
        readOnly = FALSE
      )
    }
  })

  observeEvent(input$load, {
    output$data1 <- renderRHandsontable({
      if (!is.null(data_input1())) {
        rhandsontable(move_colname_to_row(data_input1()),
          colHeaders = NULL, useTypes = FALSE,
          readOnly = FALSE
        )
      }
    })
  })

  observeEvent(input$example, {
    output$data1 <- renderRHandsontable({
      rhandsontable(move_colname_to_row(contribution::demo),
        colHeaders = NULL, useTypes = FALSE,
        readOnly = FALSE
      )
    })
  })

  observeEvent(input$clear, {
    output$data1 <- renderRHandsontable({
      rhandsontable(reset_data,
        colHeaders = NULL, useTypes = FALSE,
        readOnly = FALSE
      )
    })
  })

  DF <- reactive({
    test <<- input$data1
    df <- hot_to_r(input$data1)
    print(df)
    # browser() # uncomment for debugging
    move_row_to_colname(df)
  })
  observeEvent(input$run, {
    if (any(DF() != "")) {
      output$contribution <- renderPlot({
        contribution::generate(isolate(DF()), show_legend = TRUE)
      })
    }
  })

  output$downloadplot <- downloadHandler(
    filename = "contribution.pdf",
    content = function(file) {
      nc <- ncol(DF())
      nr <- nrow(DF())
      pdf(file, width = 1.1 * nc, height = 1.1 * nr)
      plot(contribution::generate(DF(), show_legend = TRUE))
      dev.off()
    }
  )
}

shinyApp(ui, server)
