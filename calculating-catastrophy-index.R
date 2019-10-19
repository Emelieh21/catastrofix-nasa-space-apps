# calculate catastrophy index
master_set <- readRDS("master_set.rds")

normalize <- function(x) {
  return ((x - min(x, na.rm=T)) / (max(x, na.rm=T) - min(x, na.rm=T)))
}

#### NORMALIZE VALUES ####
#master_set$lifexp_norm_rev <- 1-normalize(master_set$lifexp) # reverse to make higher = worst
#master_set$shdi_norm_rev <- 1-normalize(master_set$shdi) # reverse to make higher = worst
master_set$healthindex_norm_rev <- 1-normalize(master_set$healthindex) # reverse to make higher = worst
#master_set$pop_norm <- normalize(master_set$ES00POP)
master_set$hunger_norm <- normalize(master_set$underweight_perc)
master_set$flood_norm <- normalize(master_set$flood_decile)
master_set$drought_norm <- normalize(master_set$drought_decile)
master_set$earthquake_norm <- normalize(master_set$earthquake_decile)
master_set$landslide_norm <- normalize(master_set$landslide_decile)
master_set$cyclone_norm <- normalize(master_set$cyclone_decile)

master_set$risk_index <- rowSums(master_set[,c("hunger_norm",
                                               "flood_norm",
                                               "drought_norm",
                                               "earthquake_norm",
                                               "landslide_norm",
                                               "cyclone_norm")],na.rm = T)

# decided to put the treshhold to 0.8 based on this map https://en.wikipedia.org/wiki/Human_Development_Index
# and based on the fast that only 30 places have a hdi under 0.7
master_set$developing_area <- ifelse(master_set$shdi < 0.8, TRUE, FALSE)

df <- subset(master_set, developing_area == TRUE)
df <- subset(df, risk_index > 0.5)
df$catastrophy_index <- rowSums(df[,c("healthindex_norm_rev","risk_index")],na.rm=T)

df <- df[order(df$catastrophy_index, decreasing = T),]#[1:50,]

library(leaflet)
leaflet(df) %>%
  addTiles() %>%
  addMarkers(~LON, ~LAT, popup=~paste0(COUNTRY,": ",catastrophy_index))
