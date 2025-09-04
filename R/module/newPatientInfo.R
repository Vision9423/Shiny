newPatientInfoUI <- function() {
  
  ns <- NS('new_patient_info')
  
  tagList(
    textInput(
      inputId = ns('name'),
      label = 'ФИО пациента',
      placeholder = 'Введите ФИО пациента',
      width = '500px'
    ),
    
    dateInput(
      inputId = ns('date_birth'),
      label = 'Дата рождения пациента',
      language = 'ru',
      weekstart = 1,
      format = 'dd.mm.yyyy',
      width = '500px'
    ),
    
    radioButtons(
      inputId = ns('center'),
      label = 'Клинический центр',
      choices = list(
        'МНИОИ им. П.А. Герцена' = 0,
        'НМИЦ онкологии им. Н.Н. Блохина' = 1,
        'ММКЦ "Коммунарка"' = 2,
        'Онкологический центр № 1 ГКБ имени С.С. Юдина' = 3
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    radioButtons(
      inputId = ns('mts_interval'),
      label = 'Интервал между датой удаления первичной опухоли и датой выявления метастазирования',
      choices = list(
        '6-12 месяцев' = 0,
        'Более 12 месяцев' = 1
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    radioButtons(
      inputId = ns('fong'),
      label = 'Количество баллов по шкале Fong',
      choices = list(
        '0-2' = 0,
        '3-5' = 1
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    radioButtons(
      inputId = ns('mutation'),
      label = 'Мутационный статус',
      choices = list(
        'wtRAS' = 0,
        'mRAS' = 1
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    radioButtons(
      inputId = ns('mts_localization'),
      label = 'Локализация метастазов',
      choices = list(
        'Печень' = 0,
        'Лёгкие' = 1
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    radioButtons(
      inputId = ns('act_after_oper'),
      label = 'АХТ после хирургического удаления первичной опухоли',
      choices = list(
        'Не проводилась' = 0,
        'Проводилась' = 1
      ),
      
      inline = TRUE,
      selected = NA
    ),
    
    actionButton(
      inputId = ns('add_patient'),
      label = 'Рандомизировать пациента',
      icon = icon('hospital-user'),
      class = "btn-success"
    )
  )
  
}


newPatientInfoServer <- function(res_auth) {
  moduleServer('new_patient_info', function(input, output, session) {
    
    {
      ns <- session$ns
      
      # параметры пациента в виде реактивного списка ----
      newPatientInfo <- reactiveValues(
        name = NULL,
        date_birth = NULL,
        mts_interval = NULL,
        fong = NULL,
        mutation = NULL,
        mts_localization = NULL,
        act_after_oper = NULL,
        center = NULL
      )
      
      observeEvent(input$name, {
        newPatientInfo$name <- input$name
      })
      
      observeEvent(input$date_birth, {
        newPatientInfo$date_birth <- input$date_birth
      })
      
      observeEvent(input$mts_interval, {
        newPatientInfo$mts_interval <- input$mts_interval
      })
      
      observeEvent(input$fong, {
        newPatientInfo$fong <- input$fong
      })
      
      observeEvent(input$mutation, {
        newPatientInfo$mutation <- input$mutation
      })
      
      observeEvent(input$mts_localization, {
        newPatientInfo$mts_localization <- input$mts_localization
      })
      
      observeEvent(input$act_after_oper, {
        newPatientInfo$act_after_oper <- input$act_after_oper
      })
      
      observeEvent(input$center, {
        newPatientInfo$center <- input$center
      })
      
      # выключить выбор центра, если пользователь не админ ----
      observeEvent(res_auth$admin, {
        
        updateRadioButtons(
          inputId = 'center',
          selected = res_auth$center
        )
        
        toggle(
          id = 'center',
          condition = res_auth$admin == 1
        )
      })
      
      is_full_patient_info <- reactive(isTruthyReactiveValues(newPatientInfo))
      
      
      # выдать предупреждение, если поля не заполнены ----
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
        if (!is_full_patient_info()) {
          showNotification(
            "Не все поля заполнены",
            type = 'warning'
          )
        }
      }, ignoreInit = TRUE)
      
      
      # вызвать окно подтверждения рандомизации
      observeEvent(input$add_patient, {
        req(is_full_patient_info())
        newPatientConfirm(newPatientInfo, ns)
      })
      
      # рандомизировать пациента
      observeEvent(input$confirm_randomization, {
        req(is_full_patient_info())
        removeModal()
        randomizePatientServer(newPatientInfo)
      })
    }
    
  })
}