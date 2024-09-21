#
#
#

#
# Approximate data with an exponential function exp( a + b * x ) + c
#

fexp1 <- function ( x, a , b, c = 0 ) {
  
  return ( exp (a + b * x) + c )
  
}

fexp1s1 <- function ( x, a , b, c = 0 ) {
  
  return ( b * exp (a + b * x) )
  
}

#
#  Approximate data with a linear function a + b * x + c 
#
#  c is only used as a dummy so that the parameter are the same as in fexp1
#

flin1 <- function ( x, a , b, c  = 0) {
  
  return ( a + b * x + c )
  
}

#
# Approximate data with a sinusoidal function a + b * sin( perioden * 2 * pi * ( x + c )   )
#

fyear <- function ( x, a, b, c, perioden = 1 ) {
  
  return ( a + b * sin( perioden * 2 * pi * ( x + c ) ) ) 
  
}

#
# Determine the optimal constant c for the exponential function
# when the value is approximated by exp( a+b*x) + c.
# 

find_exp1 <- function ( data
                        , C = seq( from = 250, to = 275, by = 0.01 ) 
                        , formula = log(y) ~ x ) {
  

  tR2 <- data.table(
    R2 = rep(0,length(C))
    , a = rep(0,length(C))
    , b = rep(0,length(C))
    , c = C
  )
  
  for ( i in 1:length(C) ) {
    
  
    xy <- data
    xy$y = data$y - tR2$c[i]
    ra <- lm( formula = formula, data = xy )
    ci <- confint(ra)
    
    tR2$R2[i] = summary(ra)$r.squared
    tR2$a[i] = ra$coefficients[1]
    tR2$b[i] = ra$coefficients[2]
    
  }
  
  k = match(max(tR2$R2),tR2$R2)

  return( list(     R2 = tR2$R2[k]
                    , a  = tR2$a[k]
                    , b  = tR2$b[k]
                    , c  = tR2$c[k]
  )
  )
  
}

#
# Determine the parameters
# when the value is approximated by the linear function a + b * x + c.
# 

find_linear <- function ( data ) {
  
  ra <- lm( formula = y ~ x, data = data )
  ci <- confint(ra)
  
  return( list(   R2 = summary(ra)$r.squared
                  , a  = ra$coefficients[1]
                  , b  = ra$coefficients[2]
                  , c  = 0
  )
  )
  
}

#
# Determine the optimal constant c for the sinusoidal function
# when the value is approximated by a + b* sin( 2 * perioden * pi *(x-c) ).
# 

find_cycle <- function (data , C = seq( from = -0.25, to = 0.25, by = 0.001 ), perioden = 1 ) {
  
  tR <- data.table(
    R2 = rep(0,length(C))
    , a = rep(0,length(C))
    , a = rep(0,length(C))
    , c = C
  )
  
  for ( i in 1:length(C) ) {
    
    data$m = data$x + tR$c[i]
    
    ra <- lm( formula = y ~ sin( perioden * 2 * pi * m) , data = data )
    ci <- confint(ra)
    
    tR$R2[i] = summary(ra)$r.squared
    tR$a[i] = ra$coefficients[1]
    tR$b[i] = ra$coefficients[2]
    
  }
  
  k = match(max(tR$R2),tR$R2)

  return ( list( R2 = tR$R2[k]
               , a = tR$a[k]
               , b = tR$b[k]
               , c = tR$c[k]
               )
  
         )
}
