#
# Shiny server part
#

library(shiny)
library(leaflet)
library(dplyr)
library(feather)

# get data
# This is an open data source that contains all public transport stops in the Netherlands (oct. 2015),
# including location (latitude/longitude), name and transportation company.
#file_url <- "http://data.openov.nl/haltes/stops.csv.gz"
#download.file(file_url, "./stops.csv.bz2", mode = 'wb')
#read.csv("./stops.csv.bz2", stringsAsFactors = FALSE) %>%
#write_feather("./stops.feather")
df_stops <- read_feather("./stops.feather")
df_stops <- df_stops %>%
  filter(isscheduled == "t") %>%
  mutate(company = gsub(":.*", "", operator_id),
         popup_text = paste0(name, "<BR><CENTER><B>", "(", company, ")</B>"))
# initial coordinates for map
lat_init <- 52.1
lng_init <- 5.35
zoom_init <- 7

# Server logic to render map
shinyServer(function(input, output) {

  # initial alert text (underneath map)  
  output$textAlert <- renderText({""})

  df_stops_sel <- reactive({
    if (is.null(input$checkGroup)) {
      if (input$City == "" & input$Name == "") {
        # if no inputs, show nothing (default behaviour of checkbox inputs would be to show everything)
        df_stops %>%
        filter(0 == 1)
      } else {
        df_stops %>% 
        filter(grepl(input$City, town, ignore.case = TRUE)) %>%
        filter(grepl(input$Name, name, ignore.case = TRUE))
      }
    } else {
      df_stops %>% 
      filter(grepl(input$City, town, ignore.case = TRUE)) %>%
      filter(grepl(input$Name, name, ignore.case = TRUE)) %>%
      filter(company %in% input$checkGroup)
    }
  })
      
  #output$test <- reactive({input$City})

  output$mapNeth <- renderLeaflet({
    leaflet() %>%  
    #addTiles() %>%
    addProviderTiles(providers$Esri) %>%
    setView(lng = lng_init, lat = lat_init, zoom = zoom_init) 
  })

  observeEvent(input$submitFilters, {
    leafletProxy("mapNeth", data = df_stops_sel()) %>%
    clearMarkerClusters() %>%
    clearMarkers() %>%
    addMarkers(lat = df_stops_sel()$latitude, lng = df_stops_sel()$longitude, popup = df_stops_sel()$popup_text, 
               clusterOptions = markerClusterOptions())
    if (nrow(df_stops_sel()) == 0) {
      output$textAlert <- renderText({"The current selection does not give any results"})
    } else {
      output$textAlert <- renderText({""})
    }
    })
    
  observeEvent(input$resetZoom, {
    leafletProxy("mapNeth") %>% setView(lat = lat_init, lng = lng_init, zoom = zoom_init)
  })
  
  observeEvent(input$showInfo, {
    showModal(modalDialog("This application lets you discover the public transportation stops in The Netherlands (as of Oct. 5, 2015).
                          Your starting point is a high level overview of the country. Because of the amount of data 
                          the map is initially empty. Through filter options on the left pane you can make selections
                          of the stops you want to see. You can zoom in on the map to reveal lower level groupings 
                          of stops and individual stops. Clicking on a stop tells you its name and transportation 
                          company. You can always return to the high level overview with the 'Reset zoom' button."))
  })
})
