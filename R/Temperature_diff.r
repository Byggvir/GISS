#!/usr/bin/env Rscript
#
# Script: Temperature_diff.r
#
# Stand: 2024-06-09
# (c) 2024 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

require(data.table)
library(tidyverse)
library(lubridate)
library(scales)

library(grid)
library(gridExtra)
library(gtable)

library(ggplot2)
library(ggrepel)
library(ggtext)

library(viridis)
library(hrbrthemes)
library(ragg)

library(nortest)

# Daten

library(rjson)

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When executed in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When executing on command line 
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')

setwd(WD)

source("R/lib/myfunctions.r")
source("R/lib/rafunctions.r")
source("R/lib/mygg.r")
source("R/lib/sql.r")

outdir <- 'png/Year/Diff/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

options( 
  digits = 8
  , scipen = 8
  , Outdec = "."
  , max.print = 3000
)

# f_scale <- function(x, minC, scl) {
#   print(x)
#   return ((x - minC)/scl)
#   
# }

today <- Sys.Date()
heute <- format(today, "%d %b %Y")

title <- paste('Temperature / Anomaly difference to the previous year', sep='')
stitle <- paste ( 'Station' )

stations <- RunSQL(SQL = paste( 'select * from Stations where HasData;' ) )

for ( s in 1:nrow(stations) ) {
  
  print(s)
  
  citation <- paste0( '(cc by 4.0) 2024 by Thomas Arend\nSource:', stations$Source[s], '\nStand: ', heute )
  
  SQL = paste( 'select T1.ID, T1.Jahr, T1.Monat, T1.Temperature - T2.Temperature as Delta from Temperature as T1 join Temperature as T2 on T1.ID = T2.ID and T1.Jahr= T2.Jahr + 1 and T1.Monat = T2.Monat where T1.ID = "', stations$ID[s], '" and T1.Monat = 1 and T1.Temperature <> -99.99 and T2.Temperature <> -99.99;' , sep = '' ) 
  # print(SQL)
  dtTEMP = RunSQL(SQL = SQL)
  
  if (nrow(dtTEMP) > 100 ) {
   
      st = shapiro.test(dtTEMP[,4])
      at = ad.test(dtTEMP[,4])
      
      print(st)
      print(at)
      
      minJahr = min(dtTEMP$Jahr)
      maxJahr = max(dtTEMP$Jahr)
      
      SD = sd(dtTEMP$Delta)
      Delta2023 = dtTEMP$Delta[nrow(dtTEMP)]
    
      dtTEMP %>%  ggplot ( ) +
         geom_histogram (
           aes( x = Delta )
           # , color = 'red'
           # , fill = 'red'
           , binwidth = 0.5
        ) +
        geom_vline ( 
            xintercept = Delta2023
          , color = 'red'
          , linewidth = 1
        ) +
        geom_vline ( 
          xintercept = 2 * SD
          , color = 'red'
          , linewidth = 1
          , linetype = 'dotted'
        ) +
        geom_label( 
            aes( x = Delta2023, y  = 0, label = "2023" )
          , color = 'red'
          , vjust = 1
        ) +
        geom_richtext( 
          aes( x = 2 * SD, y  = 0, label = paste("2σ =", round(2*SD,3) ) )
          , color = 'red'
          , angle = 90
          , hjust = 0
        ) +
        
        
        scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
        scale_y_continuous( minor_breaks = NULL, labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        labs(  title = title
               , subtitle = paste( stitle, stations$Station_Name[s], 'from', minJahr, 'to', maxJahr )
               , x = 'Difference to the previous year [K]'
               , y = 'Count' 
               , colour = 'Lines'
               , fill = 'Fill'
               , caption = citation ) +
        theme_ipsum() +
        theme( axis.title.y = element_markdown()
               , plot.title = element_markdown() ) -> p
      
      myggsave(  file = paste( outdir, stations$ID[s],'.png', sep = '')
               , plot = p )
      
  }
  
}
