# функция для рендера UI всплывающего окна --------------------------------

renderUI_newPatientConfirm <- function(newPatientInfo) {
  
  name <- newPatientInfo$name
  
  date_birth <- format.Date(
    x = newPatientInfo$date_birth,
    format = '%d.%m.%Y'
  )
  
  mts_interval <- factor(
    x = newPatientInfo$mts_interval,
    levels = c(0, 1),
    labels = c('6-12 месяцев', 'Более 12 месяцев')
  )
  
  fong <- factor(
    x = newPatientInfo$fong,
    levels = c(0, 1),
    labels = c('0-2', '3-5')
  )
  
  center <- factor(
    x = newPatientInfo$center,
    levels = c(0, 1, 2, 3),
    labels = c(
      'МНИОИ им. П.А. Герцена',
      'НМИЦ онкологии им. Н.Н. Блохина',
      'ММКЦ "Коммунарка"',
      'Онкологический центр № 1 ГКБ имени С.С. Юдина'
    )
  )
  
  mutation <- factor(
    x = newPatientInfo$mutation,
    levels = c(0, 1),
    labels = c('wtRAS', 'mRAS')
  )
  
  mts_localization <- factor(
    x = newPatientInfo$mts_localization,
    levels = c(0, 1),
    labels = c('Печень', 'Лёгкие')
  )
  
  act_after_oper <- factor(
    x = newPatientInfo$act_after_oper,
    levels = c(0, 1),
    labels = c('Не проводилась', 'Проводилась')
  )
  
  tagList(
    p(strong('ФИО: '), name),
    p(strong('Дата рождения: '), date_birth),
    p(strong('Срок метастазирования: '), mts_interval),
    p(strong('Шкала Fong: '), fong),
    p(strong('Клинический центр: '), center),
    p(strong('Мутационный статус: '), mutation),
    p(strong('Локализация метастаза: '), mts_localization),
    p(strong('АХТ после первичного лечения: '), act_after_oper),
  )
}



# всплывающее окно подтверждения рандомизации -----------------------------

newPatientConfirm <- function(newPatientInfo, ns) {
  showModal(modalDialog(
    title = 'Подтвердите введенные данные',
    renderUI_newPatientConfirm(newPatientInfo),
    
    footer = tagList(
      actionButton(
        inputId = ns('confirm_randomization'),
        "Рандомизировать",
        class = "btn-success"
      ),
      modalButton("Отменить")
    ),
    
    easyClose = FALSE
  ))
}