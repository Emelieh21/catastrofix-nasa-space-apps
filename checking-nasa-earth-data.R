# checking nasa earth & other data

library(sp)
library(leaflet)
library(spatialEco)

#### SETTLEMENTS ####
# source: http://sedac.ciesin.columbia.edu/data/dataset/grump-v1-settlement-points
settlements <- read.csv("data/gl_grumpv1_ppoints_shp-settlements/glpv1.csv")
settlements <- subset(settlements, YEAR > 1999)

# checking the data
leaflet(settlements[settlements$COUNTRY == "SPAIN",]) %>%
  addTiles() %>%
  addMarkers(~LON, ~LAT)
  
#### SHDI (SUBNATIONAL HDI) ####
#https://globaldatalab.org/shdi/shapefiles/
hdi <- raster::shapefile("data/GDL-SHDI-SHP-2-human-development-index/GDL-SHDI-SHP-2.shp")
# https://globaldatalab.org/assets/2019/09/SHDI%20Complete%203.0.csv
csv <- read.csv("data/GDL-SHDI-SHP-2-human-development-index/SHDI Complete 3.0.csv", stringsAsFactors = FALSE)
sub <- subset(csv, year == 2017)
hdi <- sp::merge(hdi, sub[,c("GDLCODE","lifexp")], by.x="GDLCode", by.y="GDLCODE", all.x=T)

# checking the data
leaflet(hdi) %>%
  addTiles() %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.7, smoothFactor = 0.5,
    color = ~colorQuantile("YlOrRd", unique(hdi$lifexp))(lifexp))

#### DROUGHT MORTALITY RISK ####
shp <- raster::shapefile("data/gddrgmrt-drought/gddrgmrt.shp")

# checking the data
leaflet(shp) %>%
  addTiles() %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.7, smoothFactor = 0.5,
    color = ~colorQuantile("YlOrRd", unique(shp$DN))(DN))


#### MALNUTRITION ####
#https://sedac.ciesin.columbia.edu/data/set/povmap-global-subnational-prevalence-child-malnutrition/
# UW = Percentage of children underweight 
hunger <- raster::shapefile("D:/emeli/Downloads/hunger-shapefile/hunger.shp")


#### POINT IN POLY EXAMPLE ####
coordinates(settlements) <- c("LON", "LAT") # convert into SpatialPointsDataFrame
proj4string(settlements) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# spatial merge of stops and polygons
new_shape <- point.in.poly(settlements, shp)

# convert back to datafram
new_shape_df <- as.data.frame(new_shape)
