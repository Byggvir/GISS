use GISS;

DROP TABLE IF EXISTS `Temperature`;

CREATE TABLE IF NOT EXISTS `Temperature` (
      `ID` CHAR(11) NOT NULL
    , `Jahr` INT(11) DEFAULT 0
    , `Monat` INT(11) DEFAULT 0
    , `Temperature` DOUBLE DEFAULT -99.99
    , `Uncertainty` DOUBLE DEFAULT 0
    , PRIMARY KEY ( `ID`, `Jahr`, `Monat` )
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ;

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/Temperature.csv'      
INTO TABLE `Temperature`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

update Stations as S join Temperature as T on S.ID = T.ID set HasData = TRUE;
