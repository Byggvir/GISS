#!/usr/bin/env Rscript
#
# Script: Temperature.r
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

SJahr <- 0
mppm <- 255

aprox_CO2 <- function ( x, a , b, m) {
  
  return ( exp (a + b * x ) + m )

}
  
citation <- "© 2022-2023 by Thomas Arend\nSource: GISS"

SQL <- paste( 'select * from Stations;')
Stations = RunSQL ( SQL = SQL )

s=1

for ( s in 1:nrow(Stations) ) {
# for ( s in 1:1 ) {
        
    SQL = paste( 'select * from Temperature where ID = "', Stations$ID[s], '" and Temperature > -99.99 ;',sep = '')
    Temperature <- RunSQL( SQL = SQL )
    
    if (nrow(Temperature) > 1) {
        Temperature[, DecDate := mid_of_month(Jahr, Monat ) ]
        Temperature[, Monate := factor( Monat, levels = 1:12, labels = Monatsnamen ) ]
        
        ra1 <- lm( formula = Temperature ~ DecDate , data = Temperature )
        ci1 <- confint(ra1)
        
        Temperature %>% filter ( Monat > 0) %>% ggplot(
            aes( x = DecDate , y = Temperature ) 
          ) +
            geom_smooth ( method = 'glm' 
                          , formula = y ~ x ) +
            geom_line ( ) +
            geom_point ( ) +
          facet_wrap( vars( Monate ) ) +
          scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
          scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
          
            labs(  title = paste ( Stations$ID[s], '/', Stations$Name[s] )
                 , subtitle = paste('Temperature', sep='') 
                 , x = 'Jahr'
                 , y = 'Temperature [K]' 
                 , colour = 'Legende'
                 , caption = citation ) +
          theme_ipsum() -> p1
        
        ggsave(  file = paste( outdir, Stations$ID[s], '.png', sep = '')
                 , plot = p1
                 , bg = "white"
                 , width = 1920
                 , height = 1080
                 , units = "px"
                 , dpi = 144 )
        
    }
    
}