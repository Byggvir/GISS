Wochentage <- c("Mo","Di","Mi","Do","Fr","Sa","So")
WochentageLang <- c("Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag","Sonntag")
Monatsnamen <- c("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember")
MonatsnamenEN <- c("January","February","March","April","May","June","Juli","August","September","October","November","December")

limbounds <- function (x, zeromin=TRUE) {
  
  if (zeromin == TRUE) {
    range <- c(0,max(x,na.rm = TRUE))
  } else
  { range <- c(min(x, na.rm = TRUE),max(x,na.rm = TRUE))
  }
  if (range[1] != range[2])
  {  f <- 10^(floor(log10(range[2]-range[1])))
  } else {
    f <- 1
  }
  
  return ( c(floor(range[1]/f),ceiling(range[2]/f)) * f) 
}

#
# p-Wert eienr Regressionsanalyse ermitteln  
#

get_p_value <- function (modelobject) {
  
  if (class(modelobject) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
  
}

#
# Berechnungen zur Luftfeuchte  
#

MagnusFormel <- function (T, ice=FALSE) {
  
  if ( ! ice ) {
    return ( 611.2 * exp( 17.6200 * ( T - 273.15 ) / ( T - 30.0300) ) )
  }
  else {
    return ( 611.2 * exp( 27.4600 * ( T - 273.15 ) / ( T - 0.5300) ) )
    
  }
}

SaettigungWasser <- function(T) {
  
  return(MagnusFormel(T)/461.52/T)
  
}

# decimal_date() of the mid of a month
  
mid_of_month <- function ( Jahr, Monat) {
  
  daysInYear = data.table(
    Jahr = Jahr
    , Monat = Monat
    , days = 365
  )
  daysInYear[Jahr %% 4 == 0] <- 366
  
  firstDayOfMonth <- as.Date(paste( Jahr, 1, 1, sep = '-' ))
  firstDayOfMonth[Monat != 0] <- as.Date(paste(   Jahr[Monat != 0]
                                                , Monat[Monat != 0]
                                                , rep(1,length(Monat[Monat != 0]))
                                                , sep = '-' )
                                         )
  
  daysInMonth <- rep(0,length(Jahr))
  daysInMonth[Monat != 0] <- days_in_month(firstDayOfMonth[Monat != 0])
  return( decimal_date( firstDayOfMonth ) + daysInMonth / 2 / daysInYear$days )
          
}
