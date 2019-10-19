# combining all datasets

library(sp)
library(leaflet)
library(spatialEco)
library(raster)

#### SETTLEMENTS ####
# source: http://sedac.ciesin.columbia.edu/data/dataset/grump-v1-settlement-points
settlements <- read.csv("data/gl_grumpv1_ppoints_shp-settlements/glpv1.csv")
settlements <- subset(settlements, YEAR > 1999 & settlements$URBORRUR.C.13 == "R")
settlements$id <- row.names(settlements)

#### RUN SPATIAL MERGES ####
coordinates(settlements) <- c("LON", "LAT") # convert into SpatialPointsDataFrame
proj4string(settlements) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

#### SHDI (SUBNATIONAL HDI) ####
#https://globaldatalab.org/shdi/shapefiles/
shp <- raster::shapefile("data/GDL-SHDI-SHP-2-human-development-index/GDL-SHDI-SHP-2.shp")
# spatial merge of stops and polygons
new_shape <- point.in.poly(settlements[,("id")], shp[,c("OBJECTID")])
# convert back to dataframe
s_hdi_link <- as.data.frame(new_shape)
# add the actual data
# https://globaldatalab.org/assets/2019/09/SHDI%20Complete%203.0.csv
csv <- read.csv("data/GDL-SHDI-SHP-2-human-development-index/SHDI Complete 3.0.csv", stringsAsFactors = FALSE)
sub <- subset(csv, year == 2017)
s_hdi_link <- merge(s_hdi_link, as.data.frame(shp[,c("OBJECTID", "GDLCode")]), 
                    by="OBJECTID", all.x=T)
s_hdi_link <- merge(s_hdi_link[,c("id","OBJECTID","GDLCode")], sub[,c("GDLCODE","lifexp","shdi","healthindex","pop")], by.x="GDLCode", by.y="GDLCODE", all.x=T)

#### DROUGHT MORTALITY RISK ####
shp <- raster::shapefile("data/gddrgmrt-drought/gddrgmrt.shp")
names(shp) <- "drought_decile"
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_drought_link <- as.data.frame(new_shape)

#### FLOOD MORTALITY RISK ####
shp <- raster::shapefile("data/gdfldmrt-flood/gdfldmrt.shp")
names(shp) <- "flood_decile"
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_flood_link <- as.data.frame(new_shape)

#### EARTHQUAKE MORTALITY RISK ####
shp <- raster::shapefile("data/gdpgamrt-earthquake/gdpgamrt.shp")
names(shp) <- "earthquake_decile"
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_earthquake_link <- as.data.frame(new_shape)

#### LANDSLIDE MORTALITY RISK ####
shp <- raster::shapefile("data/gdlndmrt-landslide/gdlndmrt.shp")
names(shp) <- "landslide_decile"
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_landslide_link <- as.data.frame(new_shape)

#### CYCLONE MORTALITY RISK ####
shp <- raster::shapefile("data/gdcycmrt-cyclone/gdcycmrt.shp")
names(shp) <- "cyclone_decile"
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_cyclone_link <- as.data.frame(new_shape)

#### HUNGER / UNDER WEIGHT CHILDREN ####
shp <- raster::shapefile("data/hunger-shapefile/hunger.shp")
shp <- shp[,c("TEXTID","UW")]
names(shp) <- c("TEXTID","underweight_perc")
new_shape <- point.in.poly(settlements[c("id")], shp)
# convert back to dataframe
s_hunger_link <- as.data.frame(new_shape)

#### COMBINE ALL DATA INTO MASTER DATASET ####
settlements <- as.data.frame(settlements)
master_set <- merge(settlements, s_hdi_link, by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_flood_link[,names(s_flood_link)[!names(s_flood_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_drought_link[,names(s_drought_link)[!names(s_drought_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_earthquake_link[,names(s_earthquake_link)[!names(s_earthquake_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_cyclone_link[,names(s_cyclone_link)[!names(s_cyclone_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_landslide_link[,names(s_landslide_link)[!names(s_landslide_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
master_set <- merge(master_set, 
                    s_hunger_link[,names(s_hunger_link)[!names(s_hunger_link) %in% c("LAT","LON")]], 
                    by="id", all.x=T) 
                     
master_set$underweight_perc <- ifelse(master_set$underweight_perc == -999,NA, master_set$underweight_perc)
saveRDS(master_set, "master_set.rds")
