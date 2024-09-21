#!/usr/bin/env Rscript
#
#
# Script: Map.r
#
# Stand: 2024-06-09
# (c) 2024 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(ggmap)
library(ggrepel)
library(ggtext)

library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

library(maps); 
library(mapproj);
library(raster);
library(sf);
library(geodata);


# Daten

# library(rjson)

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When executed in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When executi on command line 
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')

setwd(WD)

source("R/lib/myfunctions.r")
source("R/lib/sql.r")
source("R/lib/georaster_DEU.r")

outdir <- 'png/Regions/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

options( 
  digits = 7
  , scipen = 7
  , Outdec = "."
  , max.print = 3000
)

today <- Sys.Date()
heute <- format(today, "%d %b %Y")


# germany <- geodata::gadm(country = 'DEU', level=2, path = tempdir(), version="latest", resolution=1)

Region = '(Germany|Austria|Switzerland)'
RegionName = 'DACHS'
#Region = '(Russia)'
#RegionName = 'Russland'

if ( Region == 'world' ) {
    
    Area <- map(database = 'world', region = '.*', plot = FALSE, fill = TRUE)
    PointSize = 1
    TextSize = 0
    A = 0.9
    
} else {
 
       Area <- map(database = 'world', region = Region, plot = FALSE, fill = TRUE )
       PointSize = 12
       TextSize = 4
       A = 1
}

    # Area2 <- map_data('world', region = 'Germany')

sfArea <- sf::st_as_sf(Area)

SQL = 'select * from Stations where Lat = 0 and Lon = 0 and Elevm = 0 and ID != "Deutschland";'
TempIdx = RunSQL( SQL = SQL )

#file.remove('data/RAErg.csv')

SQL <- paste( 'select * from RADachs;', sep = '')
RXY = RunSQL ( SQL = SQL )

for ( i in 1:nrow(TempIdx)) {

    citation <- paste( '© 2024 by Thomas Arend\nSource:', TempIdx$ID[i], '& GISS Surface Temperature Analysis (v4)' )
    
    RXY %>% filter ( IdxID == TempIdx[i,ID] ) %>%  
        ggplot( 
            ) +
          geom_point( aes( x = Lon, y = Lat, colour = b), size = PointSize, alpha = A ) +
          # geom_polygon( data = GeoXY, aes ( x=x, y = y, group = id, fill = b )) +
          geom_sf( data = sfArea, fill = NA, color = 'lightblue', linewidth = 2 ) +
          geom_text( aes( x = Lon, y = Lat, label = round( b,1 ) ), size = TextSize ) +
        
          scale_colour_gradient2(low = "green", mid='yellow', high = "red", midpoint = 2, na.value = NA ) +
          #scale_fill_gradient2( low = 'green', mid = 'yellow', high = 'red', midpoint = 2, na.value = NA ) +
          #scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
          #scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
          coord_sf( ) + 
          labs(  title = paste('Lokale Temperatur vs globale Temperaturänderung für Stationen in DEU, CHE und AUT' ) 
                 , subtitle = 'T<sub>lokal</sub> = a * T<sub>global</sub> + b<br />Lokale Steigung a'
                 , x = 'Lon'
                 , y = 'Lat' 
                 , colour = 'Lokale Steigung a'
                 , fill = 'Lokale Steigung a'
                 , caption = citation ) +
          theme_ipsum() +
          theme (
              plot.subtitle = element_markdown()
              ) -> p1
        
        ggsave(  file = paste( outdir, 'Map_', RegionName,'_', TempIdx[i,ID], '.png', sep = '')
                 , plot = p1
                 , bg = "white"
                 , width = 3840
                 , height = 2160
                 , units = "px"
                 , dpi = 144 )
}

        citation <- paste( '© 2024 by Thomas Arend\nSource: Berkeley, JMA, MetOffice, NASA, NOA und GISS Surface Temperature Analysis (v4)' )

        RXY %>% ggplot( 
        ) +
            geom_density( aes( x = b, fill = IdxID, colour = IdxID ), alpha = 0.1 ) +
            scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
            scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
            labs(  title = paste('Lokale Temperaturänderung an', nrow(RXY)/nrow(TempIdx),' Stationen in DEU, AUT und CHE gegen globale Indizes' ) 
                   , subtitle = 'T<sub>lokal</sub> = a * T<sub>global</sub> + b'
                   , x = 'Steigung a'
                   , y = 'Dichte der Steigung a' 
                   , caption = citation 
                   , colour = 'Globaler Index'
                   , fill = 'Globaler Index') +
            theme_ipsum()  +
            theme (
                plot.subtitle = element_markdown()
            ) -> p2
        
        ggsave(  file = paste( outdir, 'Dichte_', RegionName,'.png', sep = '')
                 , plot = p2
                 , bg = "white"
                 , width = 1920
                 , height = 1080
                 , units = "px"
                 , dpi = 144)
        