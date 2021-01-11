#######################################################
# Hiplot plugin interface to ggpubr ggbarplot         #
#-----------------------------------------------------#
# Author: Shixiang Wang                               #
#                                                     #
# Email: w_shixiang@163.com                           #
# Website: https://hiplot.com.cn                      #
#                                                     #
# Date: 2020-12-26                                    #
# Version: 0.1                                        #
#######################################################
#                    CAUTION                          #
#-----------------------------------------------------#
# Copyright (C) 2020 by Hiplot Team                   #
# All rights reserved.                                #
#######################################################
# Modify above by yourself

# Example command to debug
# Rscript run_debug.R -c barplot-ggpubr/data.json -i barplot-ggpubr/data.txt -o barplot-ggpubr/test -t barplot-ggpubr --enableExample

#print(str(data))
#print(conf)


# Utils -------------------------------------------------------------------
ParseString2BoolOrString = function(x) {
  y = as.logical(x)
  if (is.na(y)) {
    y = x
  }
  y
}

ParseNone2NULL = function(x) {
  if (is.null(x)) {
    x <- NULL
  } else if (x == "none") {
    x <- NULL
  }
  x
}

ParseString2FunCall = function(x) {
  if (grepl("\\(", x)) {
    eval(parse(text = x))
  } else {
    eval(parse(text = paste0(x, "()")))
  }
}

ParseInfinity = function(x, pos = TRUE) {
  if (is.character(x)) {
    x <- gsub(" ", "", x)
    if (x == "Inf") {
      x <- Inf
    } else if (x == "-Inf") {
      x <- -Inf
    } else {
      x <- NA
    }
  }

  if (is.infinite(x)) {
    if (pos) Inf else -Inf
  } else {
    x
  }
}

############# Section 1 ##########################
# input options, data and configuration section
##################################################


############# Section 2 #############
#           plot section
#####################################
{
%s
}

# message("Plotting")
# png("test.png")
# print(p)
# dev.off()
############# Section 3 #############
#          output section
#####################################
{
  export_single(p, opt, conf)
}
