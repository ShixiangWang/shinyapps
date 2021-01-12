# 功能：
# 解析函数参数并输出、支持编辑
# 转换为 json 格式
# 自动生成 ui 并支持编辑
# 导出

library(zip)
library(data.table)
library(jsonlite)
library(tidyverse)
library(shiny)
library(shinyWidgets)
library(DTedit) # https://github.com/jbryer/DTedit

RtoJSON <- function(x) {
  tryCatch(
    toJSON(x, null = "null", auto_unbox = TRUE),
    error = function(e) {
      if (class(x) == "name") {
        "" # Report void string to let user modify by themselves
      } else if (class(x) == "call") {
        x <- tryCatch(
          toJSON(eval(x), null = "null", auto_unbox = TRUE),
          error = function(e) {
            x <- as.character(x)
            idx <- !sapply(x, function(y) {
              endsWith(y, ")")
            })
            x[idx] <- paste0(x[idx], "()")
          }
        )
      } else {
        message("Currently unsupported conversion type, set it to void string, please contact the author to add it or modify by yourself.")
        message("Report conversion error message:")
        message(e$message)
        ""
      }
    }
  )
}

RfromJSON <- function(x) {
  y <- tryCatch(
    fromJSON(x),
    error = function(e) {
      x
    }
  )

  if (length(y) > 1) {
    return(x)
  } else {
    return(y)
  }
  # y
}

MakeUI <- function(x) {
  # type: select, switch, slider, text-field
  y <- sapply(x, function(i) {
    if (is.character(i)) {
      # Typically it is a select element
      list(
        type = "select",
        label = list(
          en = "English desc",
          zh = "中文描述"
        ),
        class = "col-12 col-md-6",
        items = c("<a>", "<b>", "<c>")
      )
    } else if (is.numeric(i)) {
      list(
        type = "slider",
        label = list(
          en = "English desc",
          zh = "中文描述"
        ),
        class = "col-12 col-md-6",
        max = i + 1,
        min = 0,
        step = 1
      )
    } else if (is.logical(i)) {
      list(
        type = "switch",
        label = list(
          en = "English desc",
          zh = "中文描述"
        ),
        class = "col-12 col-md-4"
      )
    } else {
      list(
        type = "text-field",
        label = list(
          en = "English desc",
          zh = "中文描述"
        ),
        class = "col-12 col-md-6"
      )
    }
  })

  y <- y %>%
    toJSON(pretty = TRUE, auto_unbox = TRUE, null = "null") %>%
    as.character()
  gsub("\n  ", "\n        ", y)
}

# 生成 Hiplot 插件模板文件
GenerateConfigs <- function(data, fun, outdir = tempfile()) {
  message("Generating hiplot plugin files in ", outdir)
  rownames(data) <- NULL
  print(data)
  if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

  data_cp <- data
  data <- data %>%
    tibble::column_to_rownames(var = "Parameter") %>%
    t() %>%
    as.data.frame()
  rownames(data) <- NULL
  # Remove "data" from data.json in "extra" map
  data_extra <- sapply(data[, colnames(data) != "data"], RfromJSON)
  data <- data_extra %>%
    toJSON(pretty = TRUE, auto_unbox = TRUE, null = "null") %>%
    as.character()
  data <- gsub("\n  ", "\n        ", data)
  # data

  # Generate data.json
  json_data <- readLines(
    if (file.exists("template_data.json")) {
      "template_data.json"
    } else {
      "hiplot-plugin-generator/template_data.json"
    }
  )
  modify_row <- grepl("%s", json_data)
  json_data[modify_row] <- sprintf(
    json_data[modify_row],
    data
  )
  writeLines(json_data, file.path(outdir, "data.json"))

  # Generate ui.json
  # Make a default ui for each "extra" elements
  json_ui <- readLines(
    if (file.exists("template_ui.json")) {
      "template_ui.json"
    } else {
      "hiplot-plugin-generator/template_ui.json"
    }
  )
  modify_row <- grepl("%s", json_ui)
  json_ui[modify_row] <- sprintf(
    json_ui[modify_row],
    MakeUI(data_extra)
  )
  writeLines(json_ui, file.path(outdir, "ui.json"))

  # Generate meta.json
  json_meta <- if (file.exists("template_meta.json")) {
    "template_meta.json"
  } else {
    "hiplot-plugin-generator/template_meta.json"
  }
  file.copy(json_meta, file.path(outdir, "meta.json"))

  # Generate Plot.R
  data_cp$plot <- ifelse(
    data_cp$Parameter == "data",
    "data",
    paste0("conf$extra$", data_cp$Parameter)
  )
  args_seq <- paste0("    ", paste(data_cp$Parameter, data_cp$plot, sep = " = "))
  args_seq[-length(args_seq)] <- paste0(args_seq[-length(args_seq)], ",")
  args_seq <- c(
    paste0("  p = ", fun, "("),
    args_seq,
    "  )"
  )
  args_seq <- paste(args_seq, collapse = "\n")
  plot_template <- readLines(
    if (file.exists("template_plot.R")) {
      "template_plot.R"
    } else {
      "hiplot-plugin-generator/template_plot.R"
    }
  )
  modify_row <- grepl("%s", plot_template)
  plot_template[modify_row] <- sprintf(
    plot_template[modify_row],
    args_seq
  )
  writeLines(plot_template, file.path(outdir, "plot.R"))

  return(c(
    file.path(outdir, "data.json"),
    file.path(outdir, "ui.json"),
    file.path(outdir, "meta.json"),
    file.path(outdir, "plot.R")
  ))
}

ParseFunArgs <- function(pkg_fun) {
  args_list <- as.list(args(pkg_fun))
  # Remove ... and elements with no name
  args_list <- args_list[!names(args_list) %in% c("...", "")]
  sapply(args_list, RtoJSON)
}

##### Create the Shiny server
server <- function(input, output) {

  observeEvent(input$userfile, {
    if (file.exists(input$userfile$datapath)) {
      # Add all functions from user file to the namespace
      source(input$userfile$datapath, local = FALSE, verbose = TRUE)
    }
  })

  data_copy <- data.frame()

  observeEvent(input$fun, {
    pkg_fun <- reactive({
      ic <- tryCatch(
        {
          class(eval(parse(text = input$fun)))
        },
        error = function(err) {
          showNotification("Function not found!", type = "error", duration = 2)
          ""
        }
      )
      if (ic != "function" & input$fun != "") {
        showNotification("Your input is not a function!", type = "warning", duration = 2)
        ""
      } else {
        input$fun
      }
    })

    if (length(pkg_fun()) != 0 & pkg_fun() != "") {
      mydata <- ParseFunArgs(eval(parse(text = pkg_fun()))) %>%
        as.data.frame() %>%
        tibble::rownames_to_column("id") %>%
        setNames(c("Parameter", "InitialValue"))
    } else {
      mydata <- data.frame(
        Parameter = character(),
        InitialValue = character(),
        stringsAsFactors = FALSE
      )
    }

    data_copy <<- mydata

    ##### Callback functions.
    my.insert.callback <- function(data, row) {
      message("Row: ", row)
      nr <- nrow(data)
      if (nr > 1) {
        data <- rbind(data[nr, ], data[1:(nr - 1), ])
      }
      message("Data table after insertion:")
      print(data)
      message("=====")

      senv <- parent.env(parent.env(environment()))
      assign("data_copy", data, envir = senv)
      return(data)
    }

    my.update.callback <- function(data, olddata, row) {
      message("Row: ", row)
      message("Data table after update:")
      print(data)
      message("=====")

      senv <- parent.env(parent.env(environment()))
      assign("data_copy", data, envir = senv)
      return(data)
    }

    my.delete.callback <- function(data, row) {
      message("Row: ", row)
      message("Data table after deletion:")
      data <- data[-row, ]
      print(data)
      message("=====")

      senv <- parent.env(parent.env(environment()))
      assign("data_copy", data, envir = senv)
      return(data)
    }

    ##### Create the DTedit object
    DTedit::dtedit(input, output,
      name = "args",
      thedata = mydata,
      edit.cols = c("Parameter", "InitialValue"),
      edit.label.cols = c("Parameter", "Initial value (in json format)"),
      # input.types = c(notes = "textAreaInput"),
      view.cols = c("Parameter", "InitialValue"),
      show.copy = FALSE,
      callback.update = my.update.callback,
      callback.insert = my.insert.callback,
      callback.delete = my.delete.callback,
      datatable.options = list(
        pageLength = 30
      )
    )
  })

  ##### 生成 data.json 和 plot.R
  output$download <- downloadHandler(
    filename = function() {
      paste("hiplot-plugin-template-", Sys.Date(), ".zip", sep = "")
    },
    contentType = "application/zip",
    content = function(file) {
      outdir <- tempfile()
      on.exit(unlink(outdir))
      backend_files <- GenerateConfigs(data_copy, fun = input$fun, outdir = outdir)
      zip::zipr(
        zipfile = file,
        files = backend_files, recurse = FALSE
      )
      showNotification("Files generated.\nPlease modify the content properly.",
        type = "message", duration = 2
      )
    }
  )
}

##### Create the shiny UI
ui <- fluidPage(
  theme = "style.css",
  # Title
  tags$div(
    id = "titleBar",
    tags$div(
      id = "container",
      tags$h1("Hiplot Plugin Generator")
    )
  ),
  # Intro
  tags$div(
    id = "outer-content",
    tags$div(
      id = "intro",
      markdown(
        "This tool is designed to convert a plotting function (mostly `ggplot2` based) to a [Hiplot platform](https://hiplot.com.cn/) plugin.\
        It will generate multiple files in the form of `.json` and `.R`.
        You need to know some about [JSON](https://www.json.org/json-en.html) when you use this shiny.
        "
      )
    )
  ),
  h3("Input"),
  fluidRow(
    column(
      6,
      shinyWidgets::searchInput(
        inputId = "fun",
        label = "Function to convert",
        btnSearch = icon("mouse"),
        btnReset = icon("remove"),
        placeholder = "ggpubr::ggboxplot",
        width = "80%"
      )),
    column(
      6,
      fileInput(
        "userfile",
        "(Optional) Upload script for your custom function",
        accept = "text/plain",
        width = "80%",
        placeholder = "Input xx.R before search"
      ))
  ),
  h3("Editable Function Parameters"),
  column(
    12,
    style = "font-size: 75%; width: 75%",
    align = "center",
    uiOutput("args")
  ),
  br(),
  br(),
  downloadButton("download", label = "Generate and download", icon = icon("download")),
  br(),
  tags$a("Read the hiplot development guidline for more", href = "https://hiplot.com.cn/docs/zh/development-guides/"),
  fluidRow(
    tags$br(),
    HTML("<p style=\"text-align:center\">&copy; 2020 <a href=\"https://shixiangwang.github.io/home/\">Shixiang Wang</a> & Hiplot<p></p>"),
    tags$br(),
    tags$script(
      type = "text/javascript",
      src = "//rf.revolvermaps.com/0/0/8.js?i=51ge0eq3k39&amp;m=7&amp;c=ff0000&amp;cr1=ffffff&amp;f=arial&amp;l=33",
      async = "async"
    )
  )
)

##### Start the shiny app
shinyApp(ui = ui, server = server)
