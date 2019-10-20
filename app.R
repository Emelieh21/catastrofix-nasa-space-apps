# app
library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(geosphere)
library(rgeos)
library(RColorBrewer)
library(readxl)

# read in the data sets
df <- readRDS("assets/catastrofix_subset.rds")
help <- read.csv("assets/db-universities-and-tech-institutes-geocoded.csv",
               stringsAsFactors = F, encoding = "UTF-8")
targets <- read_excel("assets/Official List of Proposed SDG Indicators-Excel file.xlsx")
targets$target_code <-sub(" .*", "", targets$target)

# initialize n & popup
n <- NULL
popup <- NULL
rank_matches <- NULL

ui <- dashboardPage(skin = "yellow",
                    dashboardHeader(title = "CATASTROFIX",
                                    tags$li(a(href = 'https://earthdata.nasa.gov/',
                                              img(src = 'https://www.nasa.gov/sites/all/themes/custom/nasatwo/images/nasa-logo.svg',
                                                  title = "NASA Earth Data", height = "30px"),
                                              style = "padding-top:10px; padding-bottom:10px;"),
                                            class = "dropdown")),
                    dashboardSidebar(disable = T),
                    dashboardBody(
                      # necessary to make the big map appear when opening the app
                      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                      
                      # the "find" button
                      absolutePanel(top = 100, right = 100,                         
                                    actionButton("random", "Find a place at risk"),
                                    style = "z-index: 1000;" ## z-index modification
                      ),
                      # the big map
                      leafletOutput("map", height = "100%")
                      )
                    )
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    # the initial map
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
    # picking a random place from df
    # assign to global variable so we have the variable in the next observeEvent (not the most proper way)
    n <<- sample(x = c(1:nrow(df)), size = 1)
    dat <- df[n,]
    # generating message explaining the main risks of the selected place (assigning it to global to readd the marker in the next observeEvent)
    popup <<- paste0(
      "<b>",dat$address,"</b></br>",
      "<em>Est. population of ",format(dat$ES00POP, big.mark=".", decimal.mark = ","),"</em></br>",
      "</br>",
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
             ifelse(dat$underweight_perc > 10, "<b>High percentage</b> of underweight children (more than 10%)</br>", "Percentage of underweight children under 10%</br>"),""),
      "</br><button onclick='Shiny.onInputChange(\"button_click\",  Math.random())' id='selectlocation' type='button' class='btn btn-default action-button'>Find a match</button>" # https://stackoverflow.com/questions/32897559/submit-button-in-leaflet-popup-doesnt-trigger-observeevent-in-shiny
    )
    # zooming in to the selected place the map
    leafletProxy("map", session) %>%
      clearShapes() %>%
      clearMarkers() %>%
      setView(dat$LON, dat$LAT, zoom = 6) %>%
      addMarkers(dat$LON, dat$LAT, popup=popup)
  })
  observeEvent(input$button_click, {
    # subsetting to the randomnly selected place (see input$random)
    dat <- df[n,]
    # detecting which of the columns indicating risk are relevant for this place
    relevant <- names(dat)[grepl("norm", names(dat))]
    cols <- colnames(dat)[colSums(!is.na(dat)) > 0]
    relevant <- cols[cols %in% relevant]
    
    # match with universities that can help on this topic(s)
    match <- NULL
    if ("hunger_norm" %in% relevant) {
      u <- subset(help, hunger.medical)
      u$reason <- "hunger.medical"
      match <- rbind(match, u)
    }
    if ("flood_norm" %in% relevant) {
      u <- subset(help, flood)
      u$reason <- "flood"
      match <- rbind(match, u)
    }
    if ("drought_norm" %in% relevant) {
      u <- subset(help, drought)
      u$reason <- "drought"
      match <- rbind(match, u)
    }
    if (any(c("earthquake_norm","cyclone_norm","landslide_norm") %in% relevant)) {
      u <- subset(help, natural.disasters)
      u$reason <- "natural.disasters"
      match <- rbind(match, u)
    }
    
    # rank according to most matches
    rank_matches <- match %>%
      group_by_at(names(match)[!names(match) %in% "reason"]) %>%
      summarise(count = n(),
                percentage_match = paste0(round(count/length(relevant)*100,1),"%"),
                radius_match = count/length(relevant)*10)
    
    # calculate distances of matches
    dist <- as.data.frame(distm(dat[,c("LON","LAT")], rank_matches[,c("lon","lat")], fun=distHaversine))
    dist1 <- data.frame(t(dist))
    dist1$university <- rank_matches$university
    dist1$distance_km <- dist1$t.dist./1000
    
    rank_matches <- merge(rank_matches, dist1, by="university", all.x=T)
    # assign to global variable so we have the data in the next observeEvent (not the most proper way)
    rank_matches <<- rank_matches
    
    p1<-as.matrix(dat[,c("LON","LAT")])
    p2<-as.matrix(rank_matches[,c("lon","lat")])
    
    # make "flight" lines for the matches
    df2 <-gcIntermediate(p1, p2, breakAtDateLine=T, 
                         n=100, 
                         addStartEnd=TRUE,
                         sp=T) 
    df2_rownames <- row.names(df2)

    palette_rev <- rev(brewer.pal(5, "RdYlGn"))
    pal <- colorBin(palette = palette_rev, domain = rank_matches$distance_km)
    colors <- pal(rank_matches$distance_km)
    leafletProxy("map", session) %>% 
      clearShapes() %>% 
      clearMarkers() %>%
      setView(dat$LON, dat$LAT, zoom = 4) %>%
      addMarkers(dat$LON, dat$LAT, popup = popup) %>%
      addCircleMarkers(rank_matches, lng = rank_matches$lon, lat = rank_matches$lat,
                       radius = rank_matches$radius_match, popup = paste0("<b>",rank_matches$university,"</b></br>",
                                                  "<em>Specialities: ",rank_matches$specialities,"</em></br>",
                                                  "<b>Match: </b>",rank_matches$percentage_match,"</br>",
                                                  "<b>Distance: </b>",round(rank_matches$distance_km,1)," km"),
                       color = colors,
                       opacity = 1, fillOpacity = 1) %>%
      addPolylines(data = df2, weight = 3, color = colors,
                   popup = paste0("<button onclick='Shiny.onInputChange(\"button_click2\",  ",df2_rownames,")' id='selectlocation' type='button' class='btn btn-default action-button'>Generate Proposal</button>"))
  })
  observeEvent(input$button_click2, {
    #### ADD PROPOSAL GENERATION HERE ####
    message("Clicked")
    
    # filter to the selected university
    u <- rank_matches[input$button_click2, ]
    cols <- colnames(u)[colSums(u == TRUE) > 0]
    cols <- cols[cols %in% targets$links_to]
    
    applicable_targets <- subset(targets, links_to %in% cols)
    applicable_targets <- unique(applicable_targets$target)
    dat <- df[n,]
    
    locality_info <- c(
      ifelse(!is.na(dat$flood_decile),
             ifelse(dat$flood_decile > 5, "a high risk of floods", "a hisk of floods"),""),
      ifelse(!is.na(dat$drought_decile),
             ifelse(dat$drought_decile > 5, "a high risk of drought", "a risk of drought"),""),
      ifelse(!is.na(dat$earthquake_decile),
             ifelse(dat$earthquake_decile > 5, "a high risk of earthquakes", "a risk of earthquakes"),""),
      ifelse(!is.na(dat$landslide_decile),
             ifelse(dat$landslide_decile > 5, "a high risk of landslides", "a risk of landslides"),""),
      ifelse(!is.na(dat$cyclone_decile),
             ifelse(dat$cyclone_decile > 5, "a high risk of cyclones", "a risk of cyclones"),""),
      ifelse(!is.na(dat$underweight_perc),
             ifelse(dat$underweight_perc > 10, "a high percentage of underweight children (more than 10%)", "a percentage of underweight children under 10%"),"")
    )
    locality_info <- paste(locality_info[locality_info != ""], collapse = " and ")
    
    text <- paste0("<div style = 'font-family: Calibri; font-size: 14px; margin-right:45%; margin-left:5%; margin-top:5%'>",
      u$university,"</br>",
      gsub("\\,",",</br>",u$address),"</br>",
      "</br>",
      Sys.Date(),"</br>",
      "</br>",
      "</br>",
      "Dear ",u$contact.person,",</br>",
      "</br>",
      "We are writing you to announce that we have found a project opportunity in which your university can play a key role. ",
      "With this project your university will contribute to fulfilling ",length(applicable_targets)," targets of the United Nations SDGs (Sustainable Development Goals).</br>",
      "</br>",
      "We have spotted a vulnarable settlement in ",dat$COUNTRY,", that needs people with expertise in ",u$specialities,".</br>",
      "It concerns a small rural settlement with a population of estimated ",dat$ES00POP,".</br>",
      "It struggles with ",locality_info,".",
      "</br>",
      "This place in ",dat$address," lies on a ",round(u$distance_km,1)," km distance from your faculty.</br>",
      "</br>",
      "You can apply for project funding via <a href='https://proposals.sdgfund.org/' target='_blank'>this link</a>.</br>",
      "This project aligns to the following SDGs targets: </br>",
      "<ul style = 'list-style-position: outside;'>",
      paste(paste0("<li>",applicable_targets,"</li>"),collapse = ""),
      "</ul>",
      "</br>",
      "We hope you will support us in our goal of making the world sustainable by 2030!</br>",
      "In case of further questions, don't contact us, because this is an automatically generated email.<br>",
      "</br>",
      "Kind Regards,</br>",
      "</br>",
      "</br>",
      "CatastroFix",
      "</div>"
    )
    fileConn<-file("www/proposal.html", encoding = "utf8")
    writeLines(text[1], fileConn)
    close(fileConn)
    
    showModal(modalDialog(
      title = "Important message",
      HTML("Your proposal is <a href='proposal.html' target='_blank'>here</a>.")
    ))
  })
}
shinyApp(ui, server)

