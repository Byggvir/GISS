#!/usr/bin/env Rscript
#
#
# Script: MLOTEMP_monthly.r
#
# Stand: 2023-05-21
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "NOAATEMP_year.r"

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

outdir <- 'png/MLO/Temperature/Jahr/'
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

citation <- paste( '(cc by 4.0) 2023 by Thomas Arend\nSource: R. F. Keeling, S. J. Walker, S. C. Piper and A. F. Bollenbacher;\nGISS Surface Temperature Analysis (v4) Stand:', heute)
title <- paste('Yearly average atmospheric CO2 concentrations vs Temperature', sep='')
stitle <- paste ( 'Mauna Loa Observatory, Hawaii' )

dtCO <- read.csv(file = 'data/MLORegression.csv')

TYear = 2100
TMonth = 5

TDate = mid_of_month(TYear, TMonth)
dtCO$CO2 = fexp1( x = TDate, a = dtCO$a1, b = dtCO$b1, c = dtCO$c1 ) + fyear(x = TDate, a = dtCO$a2, b = dtCO$b2, c = dtCO$c2, perioden = 1) + fyear(x = TDate, a = dtCO$a3, b = dtCO$b3, c = dtCO$c3, perioden = 2)

Station = 'NOAA'

  dtCO2TEMP = RunSQL(SQL = paste( 'select * from NOAACO2TempJahr;' ) )
  dtCO2TEMP$dT <- dtCO2TEMP$Temperature - dtCO2TEMP$Temperature[1]
  dtCO2TEMP$lnCO2 <- log(dtCO2TEMP$CO2 / dtCO2TEMP$CO2[1])
  
  minJahr = min(dtCO2TEMP$Jahr)
  
  ra = lm( formula = dT ~ lnCO2 , data =  na.exclude(dtCO2TEMP))
  ci = confint(ra)
  
  cat ( Station, '\n')
  # print(summary(ra))
  # print(ci)
  
  cat( dtCO2TEMP$Jahr[1], c(ra$coefficients[2],ci[2,]) * log(420 / dtCO2TEMP$CO2[1]) + c(ra$coefficients[1],ci[1,]) )
  cat ('\n\n')
  
  maxC = max( dtCO2TEMP$CO2, na.rm = TRUE )
  minC = min( dtCO2TEMP$CO2, na.rm = TRUE )
  maxT = max( dtCO2TEMP$Temperature, na.rm = TRUE )
  minT = min( dtCO2TEMP$Temperature, na.rm = TRUE )
  scl = ( maxC -  minC ) / (maxT -minT ) 
  
  dtCO2TEMP %>% ggplot (aes (x = Jahr ) ) +
    geom_smooth( aes(y = CO2, colour = 'CO2' )
                 , na.rm = TRUE 
                 , method = 'loess'
                 , formula = y ~ x
    ) +
    geom_smooth( aes(y = (Temperature - minT) * scl + minC, colour = 'Temperature' )
                 , na.rm = TRUE
                 , method = 'loess'
                 , formula = y ~ x
    ) +
    geom_line( aes(y = CO2, colour = 'CO2' )
               , na.rm = FALSE
               , linewidth = 2 ) +
    geom_line( aes(y = (Temperature - minT)  * scl + minC , colour = 'Temperature' )
               , na.rm = FALSE
               , linewidth = 2 ) +
    scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ),
                        sec.axis = sec_axis( trans = ~ ( . - minC ) / scl + minT , name = 'Temperature [° C]', labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
    labs(  title = title
           , subtitle = Station
           , x ='Year'
           , y = 'CO2 [ppm]' 
           , colour = 'Lines'
           , fill = 'Fill'
           , caption = citation ) +
    theme_ipsum() -> p
  
  myggsave(  file = paste( outdir, Station,'_CO2_Temperature.png', sep = '')
           , plot = p )
  
  dtCO2TEMP %>% ggplot ( aes(x = lnCO2, y = dT) )  +
    geom_smooth( method = 'lm'
                 , formula = y ~ x
                 ) +
    geom_point( size = 5 ) +
    scale_x_continuous( labels = function (x) format(x, big.mark = "", decimal.mark= ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = title
           , subtitle = Station
           , x = 'ln(CO2(t) / CO2(0))' 
           , y = 'T(t) - T(0) [° C]'
           , colour = 'Lines'
           , fill = 'Fill'
           , caption = citation ) +
    annotate( geom = "label"
              , x = 0
              , y = max(dtCO2TEMP$dT)
              , label =paste( 'T(t) - T(',minJahr,') = a * ln(CO2(t)/CO2(',minJahr,')) \na ~'
                              , round(  ra$coefficients[2],4)
                                      , '['
                                      , round(ci[2,1],4)
                                      , ','
                                      , round(ci[2,2],4)
                                      , ']' )
              , hjust = 0
              , color = "black" ) +
  
    theme_ipsum() -> p
  
  myggsave(  file = paste( outdir, Station, '_scatter.png', sep = '')
           , plot = p )
  
