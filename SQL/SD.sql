use GISS;

drop table if exists Delta_SD;

create table Delta_SD 
    ( 
        `ID` CHAR (11) DEFAULT 0
        , `Monat` INT(11) DEFAULT 0
        , `SD` DOUBLE (6,4) 
        , primary key(`ID`, `Monat`) 
    ) 
select 
    T1.`ID` as `ID`
    , stddev(T1.Temperature - T2.Temperature) as SD 
from Temperature as T1
join Temperature as T2 
on 
    T1.`ID` = T2.`ID` 
    and T1.Jahr= T2.Jahr + 1 
    and T1.Monat = T2.Monat 
where 
    T1.Monat = 1 
    and T1.Temperature <> -99.99 
    and T2.Temperature <> -99.99 
group by 
    T1.`ID`
    , T1.Monat
;
