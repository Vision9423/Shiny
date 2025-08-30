library(shiny)
library(shinymanager)
library(bslib)
library(shinybusy)
library(tidyverse, warn.conflicts = FALSE)
library(Minirand)
library(DBI)
library(RMariaDB)
library(DT)

# функция для подключения к БД
source('fun/connectDB.R')

# русский интерфейс для авторизации
source('fun/shinymanager_ru.R')

# функция для авторизации
source('fun/server_auth.R')

# функция для руссификации названия столбцов
source('fun/get_ru_colnames.R')

# функция для перевода числовых данных в фактор
source('fun/get_df_factors.R')

# функция для всплывающих окон
source('fun/modal_dialogues.R')

# функция для рандомизации
source('fun/randomization_DB.R')

# ui: рандомизировать пациента
source('ui/ui_randomize_patient.R')

# ui: база данных
source('ui/ui_data_base.R')

ui <- page_fluid(
  
  # тема приложения
  theme = bs_theme(bootswatch = 'litera'),
  
  # колесо загрузки
  add_busy_spinner(
    spin = 'fulfilling-bouncing-circle',
    color = "#112446",
    position = 'full-page'
  ),
  
  navset_pill(
    
    # рандомизация пациента
    nav_panel(
      title = 'Рандомизировать пациента',
      ui_randomize_patient
    ),
    
    # база данных рандомизированных пациентов
    nav_panel(
      title = 'База данных пациентов',
      ui_data_base
    )
    
  )
)

# активировать авторизацию в приложение
ui <- secure_app(ui)

server <- function(input, output, session) {
  
  # авторизация в приложение
  res_auth <- server_auth()
  
  output$is_admin <- reactive({
    res_auth$admin
  })
  
  outputOptions(
    x = output,
    suspendWhenHidden = FALSE
  )
  
  observeEvent(res_auth, {
    req(res_auth$center)
    
    updateRadioButtons(
      inputId = 'center',
      selected = res_auth$center
    )
  })

    # UI всплывающего окна подтверждения рандомизации пациента
  output$patient_params <- renderUI({
    renderUI_patient(
      name = input$name,
      date_birth = input$date_birth,
      mts_interval = input$mts_interval,
      fong = input$fong,
      center = input$center,
      mutation = input$mutation,
      mts_localization = input$mts_localization,
      act_after_oper = input$act_after_oper
    )
  })
  
  # вызвать окно подтверждения рандомизации
  observeEvent(input$add_patient, {
    
    req(input$name)
    
    showModal(modalDialog(
      title = 'Подтвердите введенные данные',
      uiOutput(outputId = 'patient_params'),
      
      footer = tagList(
        actionButton("confirm_action", "Рандомизировать", class = "btn-success"),
        modalButton("Отменить")
      ),
      
      easyClose = FALSE
    ))
  })
  
  # выполнить рандомизацию и добавить пациента в БД
  observeEvent(input$confirm_action, {
    req(input$name)
    
    con <- connectDB()
    on.exit(dbDisconnect(conn = con), add = TRUE)
    
    treatment <- add_patient(
      conn = con,
      name = input$name,
      date_birth = input$date_birth,
      mts_interval = as.integer(input$mts_interval),
      fong = as.integer(input$fong),
      center = as.integer(input$center),
      mutation = as.integer(input$mutation),
      mts_localization = as.integer(input$mts_localization),
      act_after_oper = as.integer(input$act_after_oper)
    )
    
    dbDisconnect(conn = con)
    on.exit(NULL, add = FALSE)
    
    # цвет сообщения в зависимости от группы
    color <- ifelse(treatment == 0, "#006400", "#FF4500")
    
    # перевести группу из числового значения в фактор
    treatment <- factor(
      x = treatment,
      levels = c(0, 1),
      labels = c('Динамическое наблюдение', 'Адъювантная химиотерапия')
    )
    
    # UI всплывающего окна подтверждения рандомизации пациента
    output$random_success <- renderUI({
      tagList(
        p(
          'Пациент', tags$b(input$name), 'рандомизирован в группу:',
          style = "text-align: center;"
        ),
        h3(
          treatment,
          style = sprintf("border: 3px solid %s;
                         padding: 10px;
                         border-radius: 10px;
                         text-align: center;
                         display: inline-block;", color)
        )
      )
    })
    
    removeModal()
    
    showModal(modalDialog(
      title = 'Успешно',
      uiOutput(outputId = 'random_success'),
      
      footer = tagList(
        modalButton("Закрыть окно")
      ),
      
      easyClose = FALSE
    ))
    
    
  })
  
  patientsDB <- eventReactive(input$get_patientsDB, {
    
    con <- connectDB()
    on.exit(dbDisconnect(conn = con), add = TRUE)
    
    patientsDB <- dbReadTable(
      conn = con,
      name = 'patients'
    )
    
    dbDisconnect(conn = con)
    on.exit(NULL, add = FALSE)
    
    # перевести числовые переменные в факторы
    # и сортировать по дате добавления (сначала новые)
    patientsDB <- patientsDB %>% 
      get_df_factors() %>% 
      arrange(
        desc(datetime_randomization),
        desc(id)
      )
    
    return(patientsDB)
  })
  
  patientsDB_colnames <- reactive({
    get_ru_colnames(patientsDB())
  })
  
  output$patientsDB <- renderDT(
    datatable(
      patientsDB(),
      colnames = patientsDB_colnames(),
      options = list(
        language = list(url = 'https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Russian.json'),
        pageLength = 20
      )
    ) %>% 
      formatDate(
        columns = 'date_birth',
        method = 'toLocaleDateString',
        params = list('ru-RU')
      ) %>% 
      formatDate(
        columns = 'datetime_randomization',
        method = 'toLocaleString',
        params = list(
          'ru-RU', 
          list(timeZone = 'Europe/Moscow', hour12 = FALSE)
        )
      )
  )
}

shinyApp(ui = ui, server = server)