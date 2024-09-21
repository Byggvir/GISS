use GISS;

delimiter //


/*
  
  Zentrum des Rasters ist der Punkt 51N, 10E
  
*/

create or replace function Latitude2RasterY ( Latitude DOUBLE, RasterSize DOUBLE ) returns INT

begin

  /* Auf der Breite 51° N entspricht 1 km ~ 0.009° Breite
  */
  
  return ( round( (Latitude - 51) / (0.009 * RasterSize) ) );
  
end; //

create or replace function RasterY2Latitude ( Y INT, RasterSize DOUBLE ) returns DOUBLE

begin

  /* Auf der Breite 51° N entspricht 1 km ~ 0.009° Breite
  */
  
  return ( 51 + Y * (0.009 * RasterSize) );
  
end; //

create or replace function Longitude2RasterX ( Longitude DOUBLE, RasterSize DOUBLE ) returns INT

begin

  /* Auf der Breite 51° N entspricht 1 km ~ 0.01430114° Länge
     ~ 0.009 / cos(51/180*pi)
  */
  
  return ( round( ( Longitude - 10 ) / (0.01430114 * RasterSize) ) );
    
end; //

create or replace function RasterX2Longitude ( X DOUBLE, RasterSize DOUBLE ) returns DOUBLE

begin

  /* Auf der Breite 51° N entspricht 1 km ~ 0.01430114° Länge
     ~ 0.009 / cos(51/180*pi)
  */
  
  return ( 10 + X * (0.01430114 * RasterSize) );
    
end; //

delimiter ;
