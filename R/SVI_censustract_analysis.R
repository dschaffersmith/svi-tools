
rm(list=ls())

library(rgdal)
library(ggplot2)
library(ggmap)
library(scales)
library(maptools)
library(rgeos)
library(dplyr)

source('R/SVI_censustracts_data.R')

############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################



############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
# A regional mapping exercise

svi.df <- readRDS('data/svi_censustract_2015.RDA')

tract <- readOGR(dsn = "shapefiles/gz_2010_06_140_00_500k", 
                 layer = "gz_2010_06_140_00_500k")
tract <- fortify(tract, region="GEO_ID")


#need the gazetteer census tracts file to get the geo id
#gaz.tracts <- read.csv('data/2012_Gaz_tracts_national.txt',sep)

# the GEO ID for a census tract is state + county + tract...
# state must have the trailing 0
# county must be 3 digit
ca.poverty <- tbl_df(svi.df) %>%
              select(name,state,county,tract,pov.pct) %>%
              filter(state=='06') %>%
              mutate(id=paste('1400000US',state,county,tract,sep=""))


plotData <- left_join(tract,ca.poverty)

county <- readOGR(dsn = "shapefiles/gz_2010_06_060_00_500k", 
                  layer = "gz_2010_06_060_00_500k")
county <- fortify(county, region="COUNTY")

#now I'm going to use the scales() package to bin the data a little
# so the contrasts in coverage rates are a little more visible
ggplot() +
  geom_polygon(data = plotData, aes(x = long, y = lat, group = group,
                                    fill = pov.pct)) +
  geom_polygon(data = county, aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  coord_map() +
  scale_fill_distiller(palette = "Greens", labels = percent,
                       breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + theme_bw()


#now try just a zoom on some North Coast areas
ggplot() +
  geom_polygon(data = subset(plotData,lat>=38 & long<=-121), aes(x = long, y = lat, group = group,
                                    fill = pov.pct)) +
  geom_polygon(data = subset(county,lat>=38 & long<=-121), aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  coord_map() +
  scale_fill_distiller(palette = "Spectral", labels = percent,
                       breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + theme_bw()

#----------------------------------------------------------------
#----------------------------------------------------------------
ca.ins <- tbl_df(svi.df) %>%
  select(name,state,county,tract,pct_no_healthins) %>%
  filter(state=='06') %>%
  mutate(id=paste('1400000US',state,county,tract,sep="")) %>%
  mutate(uninsured=pct_no_healthins)


plotData <- left_join(tract,ca.ins)


#now try just a zoom on some North Coast areas
# a few reference points 
point.df <- data.frame(name=c('Crescent City','Fort Bragg','Eureka'),
                       lat=c(41.7558,39.4457,40.8021),
                       long=c(-124.2026,-123.8053,-124.1637))

ggplot() +
  geom_polygon(data = subset(plotData,lat>=38 & long<=-121), aes(x = long, y = lat, group = group,
                                                                 fill = uninsured)) +
  geom_polygon(data = subset(county,lat>=38 & long<=-121), aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  geom_point(data=point.df,aes(x=long,y=lat),shape=18,size=3) + 
  geom_text(data=point.df,
             aes(x=long,y=lat,label=name),hjust=-0.1) + 
  coord_map() +
  scale_fill_distiller(palette = "Spectral", labels = percent,
                       breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + theme_bw()

# and what if we zoom really tight on the Eureka Port Area
ggplot() +
  geom_polygon(data = subset(plotData,lat>=40.5 & lat <= 41 & long<=-123), aes(x = long, y = lat, group = group,
                                                                 fill = uninsured)) +
  geom_polygon(data = subset(county,lat>=40.5 & lat <= 41 & long<=-123), aes(x = long, y = lat, group = group),
               fill = NA, color = "black", size = 0.25) +
  geom_point(data=subset(point.df,name=='Eureka'),aes(x=long,y=lat),shape=18,size=3) + 
  geom_text(data=subset(point.df,name=='Eureka'),
            aes(x=long,y=lat,label=name),hjust=-0.1) + 
  coord_map() +
  scale_fill_distiller(palette = "Spectral", labels = percent,
                       breaks = pretty_breaks(n = 5)) +
  guides(fill = guide_legend(reverse = TRUE)) + theme_bw()

############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

# A Map of Oregon Census Tracts
tract <- readOGR(dsn = "shapefiles/cb_2015_41_tract_500k", 
                 layer = "cb_2015_41_tract_500k")
tract <- fortify(tract, region="GEOID")


or.eng <- tbl_df(svi.df) %>%
  select(name,state,county,tract,pct_limited_eng) %>%
  filter(state=='41') %>%
  mutate(id=paste(state,county,tract,sep=""))


plotData <- left_join(tract,or.eng)

county <- readOGR(dsn = "shapefiles/cb_2015_us_county_500k", 
                  layer = "cb_2015_us_county_500k")
county <- fortify(county, region="GEOID")

ggplot() +
  geom_polygon(data = plotData, aes(x = long, y = lat, group = group,
                                    fill = pct_limited_eng)) +
#  geom_polygon(data = county, aes(x = long, y = lat, group = group),
#               fill = NA, color = "black", size = 0.25) +
  coord_map() +
  scale_fill_distiller(palette = "Spectral", labels = percent,
                       breaks = pretty_breaks(n = 5)) +
  guides(fill = guide_legend(reverse = TRUE)) + theme_bw()
