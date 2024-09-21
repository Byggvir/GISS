library(bit64)
library(RMariaDB)
library(data.table)

RunSQL <- function (
  SQL = 'select * from Faelle;'
  , prepare= c("set @i := 1;")
  , UseDB = "GISS") {
  
  rmariadb.settingsfile <- "~/R/sql.conf.d/multi.conf"
  
  rmariadb.db <- UseDB
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  for ( P in prepare ){
    dbExecute(DB, P)
  }
  rsQuery <- dbSendQuery(DB, SQL)
  dbRows<-dbFetch(rsQuery)

  # Clear the result.
  
  dbClearResult(rsQuery)
  
  dbDisconnect(DB)
  
  return(as.data.table(dbRows))
  
}

ExecSQL <- function (
  SQL
  , UseDB = "GISS"
) {
  
  rmariadb.settingsfile <- "~/R/sql.conf.d/multi.conf"
  
  rmariadb.db <- UseDB
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  
  count <- dbExecute(DB, SQL)

  dbDisconnect(DB)
  
  return (count)
  
}
