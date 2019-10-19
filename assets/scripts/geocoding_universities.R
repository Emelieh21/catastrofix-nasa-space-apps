# geocoding universities

df <- read.csv("assets/db-universities-and-tech-institutes.csv", 
               stringsAsFactors = F, encoding = "UTF-8")

library(RCurl)
library(jsonlite)
# time how long program will wait for the API to answer/download to begin
curlSetOpt(timeout = 200)
# parameters
#app_id = "<YOUR APP ID>" 
#app_code= "<YOUR APP CODE>"
df$lat <- NA
df$lon <- NA

# get city names and addresses
for (i in c(1:nrow(df))) {
  dat <- df[i,]
  apiURL <- URLencode(paste0("https://geocoder.api.here.com/6.2/geocode.json?app_id=",app_id,"&app_code=",app_code,"&searchtext=",dat$address))
  temp <- fromJSON(apiURL)
  coordinates <- as.data.frame(unlist(temp$Response$View$Result[[1]]$Location$NavigationPosition))
  if (nrow(coordinates) != 0) {
    df[i,"lat"] <- coordinates[1,]
    df[i,"lon"] <- coordinates[2,]
  }
}
df$lat[df$university == "Mongolian Academy of Sciences"] <- 47.920074
df$lon[df$university == "Mongolian Academy of Sciences"] <- 106.921803
df$lat[df$university == "Universidad de Antioquia"] <- 6.267823
df$lon[df$university == "Universidad de Antioquia"] <- -75.568820
 
con <- file("assets/db-universities-and-tech-institutes-geocoded.csv",encoding="utf8")
write.csv(df, file=con, row.names=F)

