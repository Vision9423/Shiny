db_host <- Sys.getenv('db_host')
db_port <- Sys.getenv('db_port')
db_name <- Sys.getenv('db_dbname')
db_user <- Sys.getenv('db_user')
db_password <- Sys.getenv('db_password')

connectDB <- function() {
  dbConnect(
    MariaDB(),
    host = db_host,
    port = db_port,
    dbname = db_name,
    user = db_user,
    password = db_password
  )
}