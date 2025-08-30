get_df_factors <- function(data) {
  data <- data %>% 
    mutate(
      mts_interval = factor(
        x = mts_interval,
        levels = c(0, 1),
        labels = c('6-12 месяцев', 'Более 12 месяцев')
      ),
      
      fong = factor(
        x = fong,
        levels = c(0, 1),
        labels = c('0-2', '3-5')
      ),
      
      center = factor(
        x = center,
        levels = c(0, 1, 2, 3),
        labels = c(
          'МНИОИ им. П.А. Герцена',
          'НМИЦ онкологии им. Н.Н. Блохина',
          'ММКЦ "Коммунарка"',
          'Онкологический центр № 1 ГКБ имени С.С. Юдина'
        )
      ),
      
      mutation = factor(
        x = mutation,
        levels = c(0, 1),
        labels = c('wtRAS', 'mRAS')
      ),
      
      mts_localization = factor(
        x = mts_localization,
        levels = c(0, 1),
        labels = c('Печень', 'Лёгкие')
      ),
      
      act_after_oper = factor(
        x = act_after_oper,
        levels = c(0, 1),
        labels = c('Не проводилась', 'Проводилась')
      ),
      
      treatment = factor(
        x = treatment,
        levels = c(0, 1),
        labels = c('Динамическое наблюдение', 'Адъювантная химиотерапия')
      )
    )
  
  return(data)
}