use GISS;

/*

  Add Berkeley data set
 
*/

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/Berkeley_yearly.csv'      
INTO TABLE `Temperature`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

LOAD DATA LOCAL 
INFILE '/data/git/R/GISS/data/Berkeley_monthly.csv'      
INTO TABLE `Temperature`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;
