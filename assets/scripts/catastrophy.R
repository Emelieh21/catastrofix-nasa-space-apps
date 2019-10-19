# calculate catastrophy index
master_set <- readRDS("master_set.rds")

normalize <- function(x) {
  return ((x - min(x, na.rm=T)) / (max(x, na.rm=T) - min(x, na.rm=T)))
}

#### NORMALIZE VALUES ####
master_set$hunger_norm <- normalize(master_set$underweight_perc)
master_set$flood_norm <- normalize(master_set$flood_decile)
master_set$drought_norm <- normalize(master_set$drought_decile)
master_set$earthquake_norm <- normalize(master_set$earthquake_decile)
master_set$landslide_norm <- normalize(master_set$landslide_decile)
master_set$cyclone_norm <- normalize(master_set$cyclone_decile)

# calculate an index to find the "worst" places
master_set$risk_index <- rowSums(master_set[,c("hunger_norm",
                                               "flood_norm",
                                               "drought_norm",
                                               "earthquake_norm",
                                               "landslide_norm",
                                               "cyclone_norm")],na.rm = T)

# decided to put the treshhold to 0.8 based on this map https://en.wikipedia.org/wiki/Human_Development_Index
# and based on the fast that only 30 places have a hdi under 0.7
df <- subset(master_set, shdi < 0.8 | is.na(shdi))
df <- subset(df, risk_index > 0.5)

# use the shdi to rank for urgency
df <- df[order(df$shdi),]
df$prio <- c(1:nrow(df))

# to align with SDG 11 target 11.C (developed countries helping less developed countries), taking out roughly more developed continents as a quick solution (sorry not very proper - needs to be refined with more time)
df <- subset(df, !CONTINENT %in% c("North America", "Oceania", "Europe"))
# taking georgia and cyprus out for now, because the place names returned by HERE API are unreadable
df <- subset(df, !COUNTRY %in% c("Georgia","Cyprus"))

# spatially cluster settlements and remove points that are basically the same point
lat<-df$LAT
lon<-df$LON
data=data.frame(lat,lon)

library(geosphere)
library(fields)
dist <- rdist.earth(data, miles = F,R=6371) #dist <- dist(data) if data is UTM
fit <- hclust(as.dist(dist), method = "single")
df$clusters <- cutree(fit,h = 2)
df <- subset(df, duplicated(clusters) == F)

library(RCurl)
library(jsonlite)
# time how long program will wait for the API to answer/download to begin
curlSetOpt(timeout = 200)
# parameters
#app_id = "<YOUR APP ID>" 
#app_code= "<YOUR APP CODE>"
df$address <- NA

# get city names and addresses
for (i in c(1:nrow(df))) {
  dat <- df[i,]
  apiURL <- paste0("https://reverse.geocoder.api.here.com/6.2/reversegeocode.json?app_id=",
                   app_id,"&app_code=",
                   app_code,"&mode=retrieveAddresses&prox=",dat$LAT,",",dat$LON)
  temp <- fromJSON(apiURL)
  address <- temp$Response$View$Result[[1]]$Location$Address
  df[i,"address"] <- temp$Response$View$Result[[1]]$Location$Address[1,"Label"]
}

library(leaflet)
leaflet(df) %>%
  addTiles() %>%
  addMarkers(~LON, ~LAT, popup=~paste0(COUNTRY,", ",address,": ",risk_index))

saveRDS(df, "catastrofix_subset.rds")
