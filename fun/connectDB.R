connectDB <- function() {
  dbConnect(
    MariaDB(),
    host = Sys.getenv('db_host'),
    port = Sys.getenv('db_port'),
    dbname = Sys.getenv('db_dbname'),
    user = Sys.getenv('db_user'),
    password = Sys.getenv('db_password')
  )
}