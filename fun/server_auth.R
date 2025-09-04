server_auth <- function() {
  
  # подключиться к БД
  con <- connectDB()
  on.exit(dbDisconnect(conn = con), add = TRUE)
  
  # загрузить таблицу пользователей
  credentials <- dbReadTable(conn = con, name = 'credentials')
  
  # отключиться от БД
  dbDisconnect(conn = con)
  on.exit(NULL, add = FALSE)
  
  # выбрать нужные столбцы в дата фрейме
  credentials <- credentials %>% 
    select(
      login, password, admin, center
    ) %>%
    rename(
      user = 'login'
    )
  
  # авторизация
  secure_server(
    check_credentials = check_credentials(credentials)
  )
}