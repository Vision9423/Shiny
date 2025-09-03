renderUI_randomizationResult <- function(newPatientInfo, treatment) {
  
  # цвет сообщения в зависимости от группы
  color <- ifelse(treatment == 0, "#006400", "#FF4500")
  
  # перевести группу из числового значения в фактор
  treatment <- factor(
    x = treatment,
    levels = c(0, 1),
    labels = c('Динамическое наблюдение', 'Адъювантная химиотерапия')
  )
  
  tagList(
    p(
      'Пациент', tags$b(newPatientInfo$name), 'рандомизирован в группу:',
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
}

randomizePatientServer <- function(newPatientInfo) {
  
  patient_info <- reactiveValuesToList(newPatientInfo)
  
  # рандомизировать пациента и занести его в БД
  treatment <- randomize_patient(patient_info)
  
  showModal(modalDialog(
    title = 'Пациент успешно рандомизирован и добавлен в базу данных',
    renderUI_randomizationResult(newPatientInfo, treatment),
    
    footer = tagList(
      modalButton("Закрыть окно")
    ),
    
    easyClose = FALSE
  ))
}