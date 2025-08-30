library(shiny)
library(shinymanager)
library(shinyFeedback)
library(shinybusy)
library(bslib)
library(tidyverse, warn.conflicts = FALSE)
library(Minirand)
library(DBI)
library(RMariaDB)
library(DT)

# UI ----------------------------------------------------------------------

# настройки интерфейса (тема, колесо загрузки, предупреждения)
source('ui/ui_settings.R')

# ui: рандомизировать пациента
source('ui/ui_randomize_patient.R')

# ui: база данных
source('ui/ui_data_base.R')


# функции -----------------------------------------------------------------

# подключение к БД
source('fun/connectDB.R')

# русский интерфейс для авторизации
source('fun/shinymanager_ru.R')

# авторизация
source('fun/server_auth.R')

# загрузить БД
source('fun/get_db.R')

# русифицация названия столбцов
source('fun/get_ru_colnames.R')

# перевод числовых данных в фактор
source('fun/get_df_factors.R')

# всплывающие окна
source('fun/modal_dialogues.R')

# рандомизация
source('fun/randomization_DB.R')


# модули ------------------------------------------------------------------

# рандомизация
source('module/patientsDB.R')




ui <- page_fluid(
  
  # тема интерфейса
  theme = bs_theme(bootswatch = 'litera'),
  
  # колесо загрузки и предупреждения
  ui_settings,
  
  # панели с основным интерфейсом
  navset_pill(
    
    # рандомизация пациента
    nav_panel(
      title = 'Рандомизировать пациента',
      ui_randomize_patient
    ),
    
    # база данных рандомизированных пациентов
    nav_panel(
      title = 'База данных пациентов',
      
      actionButton(
        inputId = 'get_patientsDB',
        label = 'Обновить базу данных',
        width = 350,
        icon = icon("repeat")
      ),
      
      patientsDBUI('patientsDB')
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
    
    feedbackWarning(
      inputId = 'name',
      show = !isTruthy(input$name),
      text = "Пожалуйста, заполните ФИО пациента"
    )
    
    feedbackWarning(
      inputId = 'date_birth',
      show = !isTruthy(input$date_birth),
      text = "Пожалуйста, заполните дату рождения пациента"
    )
    
    # проверить, что все данные заполнены
    patient_input <- list(
      input$mts_interval,
      input$fong,
      input$mutation,
      input$mts_localization,
      input$act_after_oper
    )
    
    is_valid_patient_input <- sapply(patient_input, isTruthy)
    
    if (!all(is_valid_patient_input)) {
      showNotification(
        "Не все поля заполнены",
        type = 'warning'
      )
    }
    
    req(
      input$name, input$date_birth, input$mts_interval,
      input$fong, input$mutation, input$mts_localization,
      input$act_after_oper
    )
    
    # вызвать всплывающее окно для подтверждения введенных данных
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
    
    req(
      input$name, input$date_birth, input$center,
      input$mts_interval, input$fong, input$mutation,
      input$mts_localization, input$act_after_oper
    )
    
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
  
  patientsDB_raw <- eventReactive(input$get_patientsDB, {
    get_db(admin = res_auth$admin, center = res_auth$center)
  })
  
  patientsDBServer('patientsDB', patientsDB_raw)
}

shinyApp(ui = ui, server = server)