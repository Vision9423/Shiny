server <- function(input, output, session) {
  
  # авторизация в приложение
  res_auth <- server_auth()
  
  # рандомизировать нового пациента
  newPatientInfoServer(res_auth)
  
  observeEvent(res_auth$user, {
    if (res_auth$admin == 1) {
      nav_show('main', 'Статистика')
    } else {
      nav_hide('main', 'Статистика')
    }
  })
  
  # обновить БД
  patientsDB_raw <- eventReactive(input$get_patientsDB, {
    get_db(res_auth)
  })

  # отрендерить таблицу
  patientsDBServer('patientsDB', patientsDB_raw, res_auth)
  
  # статистика
  statServer(res_auth)
}