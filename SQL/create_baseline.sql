use GISS;

drop table Baseline;

create table Baseline ( 
    ID char(32) primary key
    , VonJahr int(6) default 1961 
    , BisJahr int(6) default 1990
    , Quelle  char(255) default ""
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;
    
insert into Baseline values 
     ( "Berkeley", 1951, 1980, "https://berkeley-earth-temperature.s3.us-west-1.amazonaws.com/Global/Land_and_Ocean_complete.txt" )
   , ( "NASA", 1951, 1980, "https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.txt" )
   , ( "JMA", 1991, 2020, "https://www.data.jma.go.jp/tcc/tcc/products/gwp/temp/list/year_wld.html" )
   , ( "HadCRUT5", 1961, 1990, "https://climate.metoffice.cloud/formatted_data/gmt_HadCRUT5.csv" )
   , ( "NOAAGlobalTemp", 1971, 2000, "https://www.ncei.noaa.gov/data/noaa-global-surface-temperature/v5.1/access/timeseries/aravg.ann.land_ocean.90S.90N.v5.1.0.202312.asc" )
   
   ;
