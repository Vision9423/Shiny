myui <- page_navbar(

  id = 'main',

  # тема интерфейса
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#4682B4",
    # secondary = "#1ABC9C",
    success = '#0D1B2A',
    base_font = font_google("Roboto")
  ),

  title = 'Рандомизация пациентов',
  lang = 'ru',

  # колесо загрузки и предупреждения
  header = ui_settings,

  # о приложении
  nav_panel(
    title = 'О приложении',

    div(class = "container my-5",
        includeMarkdown('www/about.md')
    )

  ),

  # рандомизация пациента
  nav_panel(
    title = 'Рандомизировать пациента',

    div(class = "container my-5",
        newPatientInfoUI()
    )

  ),

  # база данных рандомизированных пациентов
  nav_panel(
    title = 'База данных пациентов',

    div(class = "container mt-2",
        actionButton(
          inputId = 'get_patientsDB',
          label = 'Обновить базу данных',
          width = 350,
          icon = icon("repeat")
        )
    ),

    div(style = "overflow-x:auto; width:100%;",
        class = "mb-5",
        patientsDBUI('patientsDB')
    )
  ),


  # статистика
  nav_panel(
    title = 'Статистика',

    div(class = "container my-2",
        statUI()
    )

  )

)

# активировать авторизацию в приложение
# ui <- secure_app(ui, fab_position = 'top-right')