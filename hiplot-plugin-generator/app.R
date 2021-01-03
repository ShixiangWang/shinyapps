# 功能：
# 解析函数参数并输出、支持编辑
# 转换为 json 格式
# 自动生成 ui 并支持编辑
# 导出

library(data.table)
library(jsonlite)
library(dplyr)
library(shiny)
library(shinyWidgets)
library(DTedit) # https://github.com/jbryer/DTedit

ParseString2BoolOrString <- function(x) {
  y <- as.logical(x)
  if (is.na(y)) {
    y <- x
  }
  y
}

# ParseNone2NULL = function(x) {
#   if (is.null(x)) {
#     x = NULL
#   }
#   x
# }

ParseString2FunCall <- function(x) {
  if (grepl("\\(", x)) {
    eval(parse(text = x))
  } else {
    eval(parse(text = paste0(x, "()")))
  }
}

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

# 根据修改后的初始化参数设定生成后端 data.json 和 plot.R 模板文件
GenerateBackendConfigs <- function() {

}

# 根据自定义调整 UI 控件后确定生成 ui.json 文件
GenerateFrontendConfigs <- function() {

}


ParseFunArgs <- function(pkg_fun) {
  args_list <- as.list(args(pkg_fun))
  # Remove ... and elements with no name
  args_list <- args_list[!names(args_list) %in% c("...", "")]
  sapply(args_list, RtoJSON)
}

##### Create the Shiny server
server <- function(input, output) {
  data_copy <- data.frame()

  observeEvent(input$fun, {
    pkg_fun <- reactive({
      ic <- tryCatch(
        {
          class(eval(parse(text = input$fun)))
        },
        error = function(err) {
          showNotification("Function not found!", type = "error")
          ""
        }
      )
      if (ic != "function") {
        showNotification("Your input is not a function!", type = "warning")
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

    data_copy <- mydata

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
  observeEvent(input$backend, {
    GenerateFrontendConfigs()
    print(data_copy)
    # download
    showNotification("Backend files generated.", type = "message")
  })
}

##### Create the shiny UI
ui <- fluidPage(
  h3("Input"),
  shinyWidgets::searchInput(
    inputId = "fun",
    label = "Function to convert",
    btnSearch = icon("mouse"),
    btnReset = icon("remove"),
    placeholder = "ggpubr::ggboxplot",
    width = "80%"
  ),
  h3("Editable Function Parameters"),
  column(
    12,
    style = "font-size: 75%; width: 75%",
    align = "center",
    uiOutput("args")
  ),
  br(),
  actionButton("backend", "Generate backend template files", icon = icon("mouse"))
)

##### Start the shiny app
shinyApp(ui = ui, server = server)
