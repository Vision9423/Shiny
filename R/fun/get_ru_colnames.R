get_ru_colnames <- function(data) {
  original_colnames <- names(data)
  
  new_colnames <- case_match(
    original_colnames,
    'id' ~ 'ID в БД',
    'patient_num' ~ 'Номер в порядке добавления',
    'patient_num_center' ~ 'Номер в порядке добавления в клиническом центре',
    'name' ~ 'ФИО пациента',
    'date_birth' ~ 'Дата рождения',
    'mts_interval' ~ 'Срок метастазирования',
    'fong' ~ 'Шкала Fong',
    'center' ~ 'Клинический центр',
    'mutation' ~ 'Мутационный статус',
    'mts_localization' ~ 'Локализация метастаза',
    'act_after_oper' ~ 'АХТ после первичного лечения',
    'treatment' ~ 'Группа',
    'datetime_randomization' ~ 'Дата и время рандомизации',
    .default = original_colnames
  )
  
  return(new_colnames)
}