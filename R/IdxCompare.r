#!/usr/bin/env Rscript
#
# Script: IdxCompare.r
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

if (rstudioapi::isAvailable()) {
    # When executed in RStudio
    SD <-
        unlist(str_split(dirname(
            rstudioapi::getSourceEditorContext()$path
        ), '/'))
    
} else {
    #  When executing on command line
    SD = (function()
        return(if (length(sys.parents()) == 1)
            getwd()
            else
                dirname(sys.frame(1)$ofile)))()
    SD <- unlist(str_split(SD, '/'))
    
}

WD <- paste(SD[1:(length(SD) - 1)], collapse = '/')

setwd(WD)

source("R/lib/myfunctions.r")
source("R/lib/rafunctions.r")
source("R/lib/mygg.r")
source("R/lib/sql.r")

# Create output directory for diagrams

outdir <- 'png/'
dir.create(outdir ,
           showWarnings = FALSE,
           recursive = FALSE,
           mode = "0777")

options(
    digits = 8
    ,
    scipen = 8
    ,
    Outdec = "."
    ,
    max.print = 3000
)

# f_scale <- function(x, minC, scl) {
#   print(x)
#   return ((x - minC)/scl)
#
# }

today <- Sys.Date()
heute <- format(today, "%d %b %Y")

citation <-
    paste0('(cc by 4.0) 2024 by Thomas Arend\n Stand: ', heute)

SQL = paste(
    'select A.ID, A.Jahr, A.Temperature as T1 from Temperature as A'
    ,
    ' join Stations as S'
    ,
    ' on A.ID = S.ID'
    ,
    ' and S.HasData = 1'
    ,
    ' where A.Monat = 0 and A.Temperature > -99.99'
    ,
    ' and A.ID <> "Deutschland"'
    ,
    ' ;' ,
    sep = ''
)
# print(SQL)

dtTEMP = RunSQL(SQL = SQL)

# Korrektur der unterschiedlichen Baselines auf 1951 - 1980

OSQL = 'select T.`ID`, T.Monat, B.VonJahr, B.BisJahr, case when (B.VonJahr = 1951 and BisJahr = 1980) then 0 else round(avg(Temperature),4) end as `Offset` from Temperature as T join Baseline as B on T.`ID` = B.`ID` where T.Jahr >= 1951 and T.Jahr <= 1980 and Monat = 0 group by T.`ID`, T.Monat;'
Offsets = RunSQL(SQL = OSQL)

for (j in 1:nrow(Offsets)) {
    if (Offsets$Offset[j] != 0) {
        dtTEMP$T1[ dtTEMP$ID == Offsets$ID[j] ] = dtTEMP$T1[ dtTEMP$ID == Offsets$ID[j] ] - Offsets$Offset[j]
    }
    
}

# Ende der Korrektur

dtTEMP %>%  ggplot (aes(x = Jahr , y = T1, colour = ID)) +
    geom_line () +
    scale_x_continuous(
        labels = function (x)
            format(
                x,
                big.mark = "",
                decimal.mark = ',',
                scientific = FALSE
            )
    ) +
    scale_y_continuous(
        minor_breaks = NULL,
        labels = function (x)
            format(
                x,
                big.mark = ".",
                decimal.mark = ',',
                scientific = FALSE
            )
    ) +
    labs(
        title = 'Vergleich der Temperatur Anomalien'
        , subtitle = paste('Daten justiert auf Baseline 1951 - 1980')
        , x = 'Jahr'
        , y = 'Anomalie [K]'
        , colour = 'Indizes'
        , caption = citation
    ) +
    theme_ipsum() +
    theme(axis.title.y = element_markdown()
          , plot.title = element_markdown()) -> p

myggsave(file = paste(outdir, 'IdxCompare.png', sep = '')
         ,
         plot = p)
