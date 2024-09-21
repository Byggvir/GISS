USE `GISS`;


/*  

  NOAA

  */


DELETE from Temperature where `ID` = 'NOAA';

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/noaa-mon.csv'      
INTO TABLE `Temperature`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/noaa-ann.csv'      
INTO TABLE `Temperature`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

/*  

  NASA

  */

DROP TABLE IF EXISTS `NASA`;

CREATE TABLE IF NOT EXISTS `NASA` (
      `Jahr` INT(11) NOT NULL
    , `Monat` INT(11) NOT NULL
    , `Temperature` DOUBLE (10,2) DEFAULT NULL
    , PRIMARY KEY ( `Jahr`, `Monat` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;
  
LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/nasa.csv'      
INTO TABLE `NASA`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

insert into Temperature 
select 
   "NASA" as `Station_Id`
  , `Jahr` as `Jahr`
  , `Monat` as `Monat`
  , `Temperature` as `Temperature`
  , 0 as `Uncertainty`
from NASA;

/*  

MetOffice annual

  */

DROP TABLE IF EXISTS `MetOffice`;

CREATE TABLE IF NOT EXISTS `MetOffice` (
      `Jahr` INT(11) NOT NULL
    , `Anomaly` DOUBLE (10,2) DEFAULT NULL
    , `Anomaly_LCL` DOUBLE (10,2) DEFAULT NULL
    , `Anomaly_UCL` DOUBLE (10,2) DEFAULT NULL
    , PRIMARY KEY ( `Jahr` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;
  
LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/MetOffice_annual.csv'      
INTO TABLE `MetOffice`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

insert into Temperature 
select 
   "MetOffice" as `Station_Id`
  , Jahr as Jahr
  , 0 as Monat
  , `Anomaly` as `Temperature`
  , (Anomaly_UCL - Anomaly_LCL) / 2 as `Uncertainty`
from `MetOffice`;

/*  

MetOffice monthly

  */

DROP TABLE IF EXISTS `MetOffice`;

CREATE TABLE IF NOT EXISTS `MetOffice` (
      Jahr INT(11) NOT NULL
    , Monat INT(11) NOT NULL  
    , Anomaly DOUBLE (10,2) DEFAULT NULL
    , Anomaly_LCL DOUBLE (10,2) DEFAULT NULL
    , Anomaly_UCL DOUBLE (10,2) DEFAULT NULL
    , PRIMARY KEY ( `Jahr`, `Monat` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;
  
LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/MetOffice_monthly.csv'      
INTO TABLE `MetOffice`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

insert into Temperature 
select 
   "MetOffice" as `Station_Id`
  , Jahr as Jahr
  , Monat as Monat
  , `Anomaly` as `Temperature`
  , 0 as `Uncertainty`
from `MetOffice`;

/* JMA  */

DROP TABLE IF EXISTS `JMA`;

CREATE TABLE IF NOT EXISTS `JMA` (
      `Jahr` INT(11) NOT NULL
    , `Global` DOUBLE (10,2) DEFAULT NULL
    , `NH` DOUBLE (10,2) DEFAULT NULL
    , `SH` DOUBLE (10,2) DEFAULT NULL
    , PRIMARY KEY ( `Jahr` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;
  
LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/jma_year_wld.csv'      
INTO TABLE `JMA`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

insert into Temperature 
select 
   "JMA" as `Station_Id`
  , `Jahr` as `Jahr`
  , 0 as `Monat`
  , `Global` as `Temperature`
  , 0 as `Uncertainty`
from `JMA`;


/* DWD: self calculated anual temperature anamaly */

/*
insert into Temperature 
select 
  'Deutschland'
  , Jahr
  , Monat
  , Anomaly
  , 2 * SAnomaly  
from dwd.KLAvgAnomaly;
*/
