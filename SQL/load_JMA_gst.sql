USE `GISS`;

DROP TABLE IF EXISTS `JMAGST`;

CREATE TABLE IF NOT EXISTS `JMAGST` (
      `Jahr` INT(6) DEFAULT 0 NULL COMMENT 'Jahr der Messung'
    , `Monat` INT(6) DEFAULT 0 COMMENT 'Monat der Messung'
    , `Lat` DOUBLE (10,2) DEFAULT 0 COMMENT 'Latitude der Messung'
    , `Lon` DOUBLE (10,2) DEFAULT 0 COMMENT 'Longitude der Messung'
    , `Temperature` DOUBLE(10,2) DEFAULT 0 COMMENT 'Anomalie'
    , PRIMARY KEY ( `Jahr`, `Monat`, `Lat`, `Lon` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;
  
LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/jma.csv'      
INTO TABLE `JMAGST`
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
IGNORE 0 ROWS;
