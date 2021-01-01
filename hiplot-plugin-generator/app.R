# 功能：
# 解析函数参数并输出、支持编辑
# 转换为 json 格式
# 自动生成 ui 并支持编辑
# 导出

library(rjson)
library(dplyr)
library(shiny)
library(DTedit) # https://github.com/jbryer/DTedit

ParseString2BoolOrString = function(x) {
  y = as.logical(x)
  if (is.na(y)) {
    y = x
  }
  y
}

# ParseNone2NULL = function(x) {
#   if (is.null(x)) {
#     x = NULL
#   }
#   x
# }

ParseString2FunCall = function(x) {
  if (grepl("\\(", x)) {
    eval(parse(text = x))
  } else {
    eval(parse(text = paste0(x, "()")))
  }
}

RtoJSON = function(x) {
  tryCatch(
    toJSON(x),
    error = function(e) {
      if (class(x) == "name") {
        "" # Report void string to let user modify by themselves
      } else if (class(x) == "call") {
        x = tryCatch(
          toJSON(eval(x)),
          error = function(e) {
            x = as.character(x)
            idx = !sapply(x, function(y) {
              endsWith(y, ")")
            })
            x[idx] = paste0(x[idx], "()")
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

ParseFunArgs = function(pkg_fun) {
  args_list = as.list(args(pkg_fun))
  # Remove ... and elements with no name
  args_list = args_list[!names(args_list) %in% c("...", "")]
  sapply(args_list, RtoJSON)
}

##### Callback functions.
my.insert.callback <- function(data, row) {
  message("Row: ", row)
  nr = nrow(data)
  if (nr > 1) {
    data = rbind(data[nr, ], data[1:(nr - 1), ])
  }
  message("Data table after insertion:")
  print(data)
  return(data)
}

my.update.callback <- function(data, olddata, row) {
  message("Row: ", row)
  message("Data table after update:")
  print(data)
  return(data)
}

my.delete.callback <- function(data, row) {
  message("Row: ", row)
  message("Data table after deletion:")
  print(data)
  return(data)
}

##### Create the Shiny server
server <- function(input, output) {
  mydata = ParseFunArgs(ggpubr::ggboxplot) %>%
    as.data.frame() %>%
    tibble::rownames_to_column("id") %>%
    setNames(c("Parameter", "InitialValue"))

  ##### Create the DTedit object
  DTedit::dtedit(input, output,
    name = "args",
    thedata = mydata,
    edit.cols = c("Parameter", "InitialValue"),
    edit.label.cols = c("Parameter", "Initial value (in json format)"),
    # input.types = c(notes = "textAreaInput"),
    view.cols = c("Parameter", "InitialValue"),
    callback.update = my.update.callback,
    callback.insert = my.insert.callback,
    callback.delete = my.delete.callback,
    datatable.options = list(
      pageLength = 30
    )
  )
}

##### Create the shiny UI
ui <- fluidPage(
  h3("Editable Function Parameters"),
  uiOutput("args")
)

##### Start the shiny app
shinyApp(ui = ui, server = server)
