connectDB <- function() {
  if (db_host == "" || db_name == "" || db_user == "" || db_password == "") {
    stop("❌ Не заданы все переменные окружения для подключения к базе данных")
  }

  dbConnect(
    MariaDB(),
    host = db_host,
    port = db_port,
    dbname = db_name,
    user = db_user,
    password = db_password
  )
}