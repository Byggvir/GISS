#!/usr/bin/env Rscript
#
# Script: RA_Hist.r
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
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

library(maps); 
library(mapproj);

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

citation <- paste( '© 2022-2024 by Thomas Arend\nSource:', TempIdx$ID[i] )

    SQL <- paste( 'select * from Stations as S join RAErg as R on S.ID = R.ID ;', sep = '')
    
    Stations = RunSQL ( SQL = SQL )
    
        Stations %>% filter ( BisJahr == 2023 & Jahre >= 50 ) %>% ggplot(
            aes( x = b, colour = IdxID ) 
          ) +
          geom_density( ) +

          scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
          scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
          labs(  title = 'Vergleich der jährlichen ø-Temperatur der Messstationen mit der globalen Anomaly'
                 , subtitle = paste('Dichte des Korrelationsfators b\nTemperature(local) ~ b * Anomaly(global) + a', sep = '' )
                 , x = 'Koeffizient b'
                 , y = 'Dichte' 
                 , colour = 'Temperatur Index / Anomaly'
                 , caption = citation ) +
          theme_ipsum() -> p1
        
        ggsave(  file = paste( outdir, 'RA_Histogram.png', sep = '')
                 , plot = p1
                 , bg = "white"
                 , width = 1920
                 , height = 1080
                 , units = "px"
                 , dpi = 144 )
