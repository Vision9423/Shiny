ui_data_base <- tagList(
  actionButton(
    inputId = 'get_patientsDB',
    label = 'Обновить базу данных',
    width = 350,
    icon = icon("repeat")
  ),
  
  DTOutput('patientsDB')
)