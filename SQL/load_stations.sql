use GISS;

DROP TABLE IF EXISTS `Stations`;

CREATE TABLE IF NOT EXISTS `Stations` (
      `ID` CHAR(11) NOT NULL
    , `Lat` DOUBLE DEFAULT 0
    , `Lon` DOUBLE DEFAULT 0
    , `Elevm` DOUBLE DEFAULT 0
    , `Name` CHAR(64) NOT NULL
    , `BI` INT (11)
    , HasData BOOLEAN DEFAULT FALSE 
    , PRIMARY KEY ( `ID` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/Stations.csv'      
INTO TABLE `Stations`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;


insert into Stations values ( "Berkeley", 0, 0, 0, "Berkeley Estimated Global Surface Temperature Anomaly", 0, TRUE);
insert into Stations values ( "Deutschland", 0, 0, 0, "Deutschland", 0, TRUE);
insert into Stations values ( "JMA", 0, 0, 0, "JMA", 0, TRUE);
insert into Stations values ( "MetOffice", 0, 0, 0, "MetOffice", 0, TRUE);
insert into Stations values ( "NASA", 0, 0, 0, "NASA/GISS GLOBAL Land-Ocean Temperature Index", 0, TRUE);
insert into Stations values ( "NOAA", 0, 0, 0, "NOAA Global Land and Ocean Temperature Anomalies", 0, TRUE);
