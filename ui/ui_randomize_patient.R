ui_randomize_patient <- tagList(
  textInput(
    inputId = 'name',
    label = 'ФИО пациента',
    placeholder = 'Введите ФИО пациента',
    width = '500px'
  ),
  
  dateInput(
    inputId = 'date_birth',
    label = 'Дата рождения пациента',
    language = 'ru',
    weekstart = 1,
    format = 'dd.mm.yyyy',
    width = '500px'
  ),
  
  conditionalPanel(
    condition = "output.is_admin == 1",
    
    radioButtons(
      inputId = 'center',
      label = 'Клинический центр',
      choices = list(
        'МНИОИ им. П.А. Герцена' = 0,
        'НМИЦ онкологии им. Н.Н. Блохина' = 1,
        'ММКЦ "Коммунарка"' = 2,
        'Онкологический центр № 1 ГКБ имени С.С. Юдина' = 3
      ),
      
      inline = TRUE
    )
  ),
  
  radioButtons(
    inputId = 'mts_interval',
    label = 'Интервал между датой удаления первичной опухоли и датой выявления метастазирования',
    choices = list(
      '6-12 месяцев' = 0,
      'Более 12 месяцев' = 1
    ),
    
    inline = TRUE,
    selected = NA
  ),
  
  radioButtons(
    inputId = 'fong',
    label = 'Количество баллов по шкале Fong',
    choices = list(
      '0-2' = 0,
      '3-5' = 1
    ),
    
    inline = TRUE,
    selected = NA
  ),
  
  radioButtons(
    inputId = 'mutation',
    label = 'Мутационный статус',
    choices = list(
      'wtRAS' = 0,
      'mRAS' = 1
    ),
    
    inline = TRUE,
    selected = NA
  ),
  
  radioButtons(
    inputId = 'mts_localization',
    label = 'Локализация метастазов',
    choices = list(
      'Печень' = 0,
      'Лёгкие' = 1
    ),
    
    inline = TRUE,
    selected = NA
  ),
  
  radioButtons(
    inputId = 'act_after_oper',
    label = 'АХТ после хирургического удаления первичной опухоли',
    choices = list(
      'Не проводилась' = 0,
      'Проводилась' = 1
    ),
    
    inline = TRUE,
    selected = NA
  ),
  
  actionButton(
    inputId = 'add_patient',
    label = 'Рандомизировать пациента',
    icon = icon('hospital-user'),
    class = "btn-success"
  )
)