#
# Shiny UI part
#

library(shiny)
library(leaflet)
library(RColorBrewer)


# UI logic
shinyUI(fluidPage(
  fluidRow(column(10, offset = 1, align = "center",
                  h2("Public Transportation Stops in the Netherlands")
                  ),
           column(1)),
  fluidRow(column(11, offset = 1)),
  fluidRow(column(3, offset = 1, 
                  checkboxGroupInput("checkGroup", 
                                     "Select Transportation Company", 
                                     choices = list("Arriva" = "ARR", 
                                                    "Connexxion" = "CXX", 
                                                    "EBS" = "EBS",
                                                    "GVB" = "GVB",
                                                    "HTM" = "HTM",
                                                    "IFF" = "IFF",
                                                    "Ohm" = "OHMSHUTTLE",
                                                    "QBuzz" = "QBUZZ",
                                                    "RET" = "RET",
                                                    "Syntus" = "SYNTUS",
                                                    "VTN" = "VTN"
                                     ),
                                     selected = ""),
                  textInput("City", "Search City"),
                  textInput("Name", "Search Stop Name"),
                  actionButton("submitFilters", "Submit filters")
                  #textOutput("test")
                  ),
           column(1,
                  actionButton("showInfo", "About", width = '100px'),
                  actionButton("resetZoom", "Reset zoom", width = '100px')
                  ),
           column(6,
                  leafletOutput("mapNeth", height = "500px"),
                  textOutput("textAlert"),
                  tags$head(tags$style("#textAlert{color: red; font-size: 20px; font-style: bold}"))
                  ),
           column(1)),
  fluidRow(column(12))
))