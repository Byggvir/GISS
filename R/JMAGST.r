#!/usr/bin/env Rscript
#
# Script: JMAGST.r
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

outdir <- 'png/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

options( 
  digits = 7
  , scipen = 7
  , Outdec = "."
  , max.print = 3000
)

today <- Sys.Date()
heute <- format(today, "%d %b %Y")

citation <- paste( '© 2022-2023 by Thomas Arend\nSource:', TempIdx$ID[i] )

# germany <- geodata::gadm(country = 'DEU', level=2, path = tempdir(), version="latest", resolution=1)

Region = 'world'
RegionName = 'world'

if ( Region == 'world' ) {
    
    Area <- map(database = 'world', region = '.*', plot = FALSE, fill = TRUE)
    PointSize = 1
    TextSize = 0
    A = 0.9
    
} else {
 
       Area <- map(database = 'world', region = Region, plot = FALSE, fill = TRUE )
       PointSize = 8
       TextSize = 2
       A = 1
}

    # Area2 <- map_data('world', region = 'Germany')

sfArea <- sf::st_as_sf(Area)

SQL = 'select * from JMAGST where Jahr = 2023 and Monat = 6;'
Temp = RunSQL( SQL = SQL )


Temp %>% 
    filter ( 
        Area$range[1] < Lon
        & Area$range[2] > Lon
        & Area$range[3] < Lat
        & Area$range[4] > Lat
    ) %>% 
    ggplot( ) +
      geom_sf( data = sfArea ) +
      geom_point( aes( x = Lon, y = Lat, colour = Temperature), size = 4, alpha = 0.5 ) +
#          scale_colour_gradient(low = "blue", high = "red", na.value = NA ) +
      scale_colour_gradient2(low = "blue", mid='yellow', high = "red", midpoint = 0, na.value = NA ) +
      coord_sf( ) + 
      labs(  
          title = paste('JMA Global Surface Temperatur Anomaly') 
        , subtitle = 'Dezember 2023'
        , x = 'Lon'
        , y = 'Lat' 
        , colour = 'Anomaly'
        , caption = citation ) +
      theme_ipsum() -> p1

    ggsave(  
          file = paste( outdir, 'JMAGST_', RegionName, '.png', sep = '')
        , plot = p1
        , bg = "white"
        , width = 1920
        , height = 1080
        , units = "px"
        , dpi = 144 
    )
