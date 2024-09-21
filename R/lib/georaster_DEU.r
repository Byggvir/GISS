#!/usr/bin/env Rscript
#
#
# Script: geo_raster_Deutschland
#
# Stand: 2024-03-23
# (c) 2020 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

# Raster für Wetterbetrachtungen in Deutschland

DEU_area = list (
  
  Lat = c(47.27881, 55.05874)
  , Lon = c(5.85752, 15.01660)
)

DEU_center = list(
  Lat = round(mean(DEU_area$Lat))
  , Lon = round(mean(DEU_area$Lon))
)

DEU_square_size =
  list(
      Lat = 360 / 40000
    , Lon = 360 / 40000 / cos( 51/180*pi )
  )

DEU_points = list (
  Lat =   ceiling( ( DEU_center$Lat - DEU_area$Lat[1] ) / DEU_square_size$Lat )
        + ceiling( ( DEU_area$Lat[2] - DEU_center$Lat ) / DEU_square_size$Lat)
        + 1
  ,
  Lon =   ceiling( ( DEU_center$Lon - DEU_area$Lon[1] ) / DEU_square_size$Lon )
        + ceiling( ( DEU_area$Lon[2] - DEU_center$Lon ) / DEU_square_size$Lon )
        + 1
)

DEU_raster = list (
      Lat = c( DEU_center$Lat - ceiling( ( DEU_center$Lat - DEU_area$Lat[1] ) / DEU_square_size$Lat )  * DEU_square_size$Lat
             , DEU_center$Lat + ceiling( ( DEU_area$Lat[2] - DEU_center$Lat ) / DEU_square_size$Lat )  * DEU_square_size$Lat
    )
    , Lon = c( DEU_center$Lon - ceiling( ( DEU_center$Lon - DEU_area$Lon[1] ) / DEU_square_size$Lon )  * DEU_square_size$Lon
             , DEU_center$Lon + ceiling( ( DEU_area$Lon[2] - DEU_center$Lon ) / DEU_square_size$Lon )  * DEU_square_size$Lon
    )
)

DEU_points = list (
  Lat =   ceiling( ( DEU_center$Lat - DEU_area$Lat[1] ) / DEU_square_size$Lat )
        + ceiling( ( DEU_area$Lat[2] - DEU_center$Lat ) / DEU_square_size$Lat)
        + 1
  ,
  Lon =   ceiling( ( DEU_center$Lon - DEU_area$Lon[1] ) / DEU_square_size$Lon )
        + ceiling( ( DEU_area$Lon[2] - DEU_center$Lon ) / DEU_square_size$Lon )
        + 1
)

Latitude2RasterY <- function ( Latitude, RasterSize ) {
  
  return ( round( (Latitude - DEU_center$Lat) / (DEU_square_size$Lat * RasterSize ) ) )

}

Longitude2RasterX <- function ( Longitude, RasterSize ) {
  
  return ( round( (Longitude - DEU_center$Lon)/ (DEU_square_size$Lon * RasterSize ) ) )
  
}

RasterY2Latitude <- function ( Y, RasterSize ) {
  
  return ( DEU_center$Lat + Y * (DEU_square_size$Lat * RasterSize ) )
  
}

RasterX2Longitude <- function ( X, RasterSize ) {
  
  return ( DEU_center$Lon + X * (DEU_square_size$Lon * RasterSize ) )
  
}

Point2Polygon <- function ( x , y , RasterSize ) {
    
  P = data.table(
    x = c( 
        RasterX2Longitude( x - 0.5, RasterSize )
      , RasterX2Longitude( x - 0.5, RasterSize )
      , RasterX2Longitude( x + 0.5, RasterSize )
      , RasterX2Longitude( x + 0.5, RasterSize )
    ) ,
    y = c( 
      RasterY2Latitude( y - 0.5, RasterSize )
      , RasterY2Latitude( y + 0.5, RasterSize )
      , RasterY2Latitude( y + 0.5, RasterSize )
      , RasterY2Latitude( y - 0.5, RasterSize )
      
    )
  )
  return(P)
  
}

RasterPoint2Polygon <- function ( RasterPoint , RasterSize ) {
  

  RasterPolygon <- data.table (
    
    id = NULL
    , x = NULL
    , y = NULL
    
  )
  
  for (i in 1:nrow(RasterPoint)) {
    
    xy = Point2Polygon( RasterPoint[i,1], RasterPoint[i,2], RasterSize ) 
 
    xy$id = rep(paste(RasterPoint[i,1], RasterPoint[i,2], sep = '/'), each = 4)
    
    RasterPolygon <- rbind(RasterPolygon, xy)
    
  }
  
  return(RasterPolygon)

}

