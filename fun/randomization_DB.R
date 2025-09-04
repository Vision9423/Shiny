# library(dplyr)
# library(Minirand)
# library(DBI)
# library(RMariaDB)

add_patient <- function(conn, name, date_birth, mts_interval, fong, center, mutation,
                        mts_localization, act_after_oper) {
  
  # получить таблицу пациентов
  patientsDB <- dbReadTable(conn = conn, name = 'patients')
  
  # рандомизировать группу
  
  if (nrow(patientsDB) == 0) {
    
    treatment <- sample(x = 0:1, size = 1, replace = TRUE, prob = c(0.5, 0.5))
    
  } else {
    
    # получить вектор групп ранее рандомизированных пациентов
    result <- pull(patientsDB, var = 'treatment')
    
    # оставить столбцы в БД, необходимые для рандомизации
    patients_df <- patientsDB %>% 
      select(mts_interval, fong, center, mutation, mts_localization,
             act_after_oper)
    
    # создать дата фрейм с новым пациентом
    new_patient <- tibble(
      mts_interval = mts_interval,
      fong = fong,
      center = center,
      mutation = mutation,
      mts_localization = mts_localization,
      act_after_oper = act_after_oper
    )
    
    # добавить нового пациента в дата фрейм
    patients_df_updated <- bind_rows(
      patients_df, new_patient
    )
    
    # номер нового пациента в БД
    j = nrow(patients_df_updated)
    
    # провести рандомизацию
    treatment <- Minirand(
      covmat = patients_df_updated,
      j = j,
      covwt = rep(x = 1/6, times = 6),
      ratio = c(1, 1),
      ntrt = 2,
      trtseq = c(0, 1),
      method = 'Range',
      result = result,
      p = 0.9
    )
    
  }
  
  # запрос для занесения нового пациента в БД
  query <- "INSERT INTO patients (name, date_birth, mts_interval, fong,
      center, mutation, mts_localization, act_after_oper, treatment)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
  
  # занести нового пациента в БД
  dbExecute(
    conn = conn,
    statement = query,
    params = list(
      name, date_birth, mts_interval, fong, center, mutation,
      mts_localization, act_after_oper, treatment
    )
  )
  
  cat('Новый пациент успешно добавлен в БД\n')
  return(treatment)
}