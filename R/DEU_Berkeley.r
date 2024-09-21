#!/usr/bin/env Rscript
#
# Script: DEU_Berkeley.r
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

outdir <- 'png/'
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

title <- paste('Temperature Anomaly 
               ', sep='')

stitle <- paste ( 'Station' )
 
  citation <- paste0( '(cc by 4.0) 2024 by Thomas Arend\nSource: NASA, Berkeley\n Stand: ', heute )
  
  S = 'Tamanrasset'
  S_ID = "NASA"
  
  SQL = paste(    'select A.Jahr, A.Temperature as T1, B.Temperature as T2 from Temperature as A'
                , ' join Temperature as B'
                , ' on A.ID = "NASA" and B.ID = "MetOffice"'
                , ' and A.Jahr = B.Jahr and A.Monat = B.Monat'
                , ' where A.Monat = 0 and A.Temperature > -99.99'
                , ' and B.Temperature > -99.99;' , sep = '' ) 
  # print(SQL)
  
  dtTEMP = RunSQL(SQL = SQL)
  
  ra = lm( dtTEMP, formula = 'T1 ~ T2')
  print(summary(ra))

    dtTEMP %>%  ggplot ( aes(x = T2 ,y = T1) ) +
        geom_point ( ) +
        geom_smooth( method = 'lm', formula = 'y ~ x') +
        geom_label_repel( aes(label = Jahr) , size = 2, max.overlaps = 100 ) +
        scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
        scale_y_continuous( minor_breaks = NULL, labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        labs(  title = title
               , subtitle = 'NASA vs Berkeley'
               , x = 'Anomalie Berkeley Baseline 1951-1980[K]'
               , y = 'Anomalie NASA GISS [C]' 
               , colour = 'Lines'
               , caption = citation ) +
        theme_ipsum() +
        theme( axis.title.y = element_markdown()
               , plot.title = element_markdown() ) -> p
      
      myggsave(  file = paste( outdir, 'NASA-Berkeley.png', sep = '')
               , plot = p )
      