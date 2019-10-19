# app

library(shiny)
library(shinydashboard)
library(leaflet)

df <- readRDS("assets/catastrofix_subset.rds")
help <- read.csv("assets/db-universities-and-tech-institutes.csv", stringsAsFactors = F)


ui <- dashboardPage(skin = "yellow",
                    dashboardHeader(title = "CATASTROFIX",
                                    tags$li(a(href = 'https://earthdata.nasa.gov/',
                                              img(src = 'https://www.nasa.gov/sites/all/themes/custom/nasatwo/images/nasa-logo.svg',
                                                  title = "NASA Earth Data", height = "30px"),
                                              style = "padding-top:10px; padding-bottom:10px;"),
                                            class = "dropdown")),
                    dashboardSidebar(disable = T),
                    dashboardBody(
                      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                      absolutePanel(top = 100, right = 100,                         
                                    actionButton("random", "Find a Match"),
                                    style = "z-index: 1000;" ## z-index modification
                      ),
                      leafletOutput("map", height = "100%")
                      )
                    )
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("OpenStreetMap.DE", group = "OpenStreetMap.DE") %>%
      addProviderTiles("CartoDB.DarkMatter", group = "CartoDB.DarkMatter") %>%
      addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
      addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
      addProviderTiles("Stamen.TonerLite", group = "Stamen.TonerLite") %>%
      setView(lng = 3.7038, lat = 40.4168, zoom = 2) %>%
      addLayersControl(position = 'bottomleft',
                       baseGroups = c("Esri.WorldImagery","OpenStreetMap.DE","CartoDB.Positron","Stamen.TonerLite","CartoDB.DarkMatter"),
                       options = layersControlOptions(collapsed = TRUE)) 
  })
  observeEvent(input$random, {
    n = sample(x = c(1:nrow(df)), size = 1)
    dat <- df[n,]
    dat$popup <- paste0(
      "<b>",dat$address,"</b></br>",
      "<em>Est. population of ",format(dat$ES00POP, big.mark="."),"</em></br>",
      ifelse(!is.na(dat$flood_decile),
             ifelse(dat$flood_decile > 5, "<b>High risk</b> of floods</br>", "Risk of floods</br>"),""),
      ifelse(!is.na(dat$drought_decile),
             ifelse(dat$drought_decile > 5, "<b>High risk</b> of drought</br>", "Risk of drought</br>"),""),
      ifelse(!is.na(dat$earthquake_decile),
             ifelse(dat$earthquake_decile > 5, "<b>High risk</b> of earthquakes</br>", "Risk of earthquakes</br>"),""),
      ifelse(!is.na(dat$landslide_decile),
             ifelse(dat$landslide_decile > 5, "<b>High risk</b> of landslides</br>", "Risk of landslides</br>"),""),
      ifelse(!is.na(dat$cyclone_decile),
             ifelse(dat$cyclone_decile > 5, "<b>High risk</b> of cyclones</br>", "Risk of cyclones</br>"),""),
      ifelse(!is.na(dat$underweight_perc),
             ifelse(dat$underweight_perc > 10, "<b>High percentage</b> of underweight childeren (more than 10%)</br>", "Percentage of underweight childeren under 10%</br>"),"")
    )
    leafletProxy("map", session) %>%
      clearControls() %>%
      clearMarkers() %>%
      setView(dat$LON, dat$LAT, zoom = 6) %>%
      addMarkers(dat$LON, dat$LAT, popup=dat$popup)
  })
}
shinyApp(ui, server)

