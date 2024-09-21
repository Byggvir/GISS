use GISS;

create or replace view RADachs as
select 
    S.*
    , Longitude2RasterX(S.Lon,100) as X
    , Latitude2RasterY(S.Lat,100) as Y
    , R.IdxID as IdxID
    , R.a as a
    , R.b as b
    , R.Jahre as Jahre
    , R.VonJahr as VonJahr
    , R.BisJahr as BisJahr 
from Stations as S 
join RAErg as R
on
    S.`ID` = R.`ID` 
    
where
    5.85752 <= S.Lon
    and 17.14736 >= S.Lon
    and 45.83003 <= S.Lat
    and 55.05874 >= S.Lat
    and R.Jahre >= 30
    and R.BisJahr > 2000
;
