randomize_patient <- function(newPatientInfo) {

  # преобразовать данные в числовой тип
  newPatientInfo <- modify_at(
    newPatientInfo,
    c(
      "mts_interval", "fong", "mutation",
      "mts_localization", "act_after_oper",
      "center"
    ),
    as.numeric
  )
  
  # подключиться к БД
  con <- connectDB()
  on.exit(dbDisconnect(conn = con), add = TRUE)
  
  # Попробовать взять блокировку на 20 секунд
  dbExecute(con, "SELECT GET_LOCK('patient_randomization', 20)")


  # Проверить, взяли ли мы лок
  lock_acquired <- dbGetQuery(con, "SELECT IS_USED_LOCK('patient_randomization')")
  if (is.na(lock_acquired[[1]])) {
    stop("Не получилось рандомизировать пациента, повторите попытку")
  }

  # Освободить блокировку при выходе
  on.exit({
    dbExecute(con, "SELECT RELEASE_LOCK('patient_randomization')")
  }, add = TRUE, after = FALSE)
  
  # получить таблицу пациентов
  patientsDB <- dbReadTable(conn = con, name = 'patients')
  
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
      mts_interval = newPatientInfo$mts_interval,
      fong = newPatientInfo$fong,
      center = newPatientInfo$center,
      mutation = newPatientInfo$mutation,
      mts_localization = newPatientInfo$mts_localization,
      act_after_oper = newPatientInfo$act_after_oper
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
    conn = con,
    statement = query,
    params = list(
      newPatientInfo$name, newPatientInfo$date_birth,
      newPatientInfo$mts_interval, newPatientInfo$fong,
      newPatientInfo$center, newPatientInfo$mutation,
      newPatientInfo$mts_localization,
      newPatientInfo$act_after_oper, treatment
    )
  )
  
  return(treatment)
}