db_host <- Sys.getenv('db_host')
cat(paste0(
  '\n\n\n\n\n\n',
  db_host,
  '\n\n\n\n\n\n'
))

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