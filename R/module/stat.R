statUI <- function() {
  
  ns <- NS('stat')
  
  tagList(
    
    actionButton(
      ns('get_stat'),
      'Обновить статистику',
      width = 350,
      icon = icon("repeat")
    ),
    
    uiOutput(ns('statUI'))
  )
  
}




statServer <- function(res_auth) {
  moduleServer('stat', function(input, output, session) {
    
    stat_list <- reactiveValues(
      n_patients = NULL,
      stat_by_center = NULL,
      stat_by_treatment = NULL
    )
    
    observeEvent(input$get_stat, {
      data <- get_db(res_auth) %>% 
        
        # преобразовать числовые данные в факторы
        get_df_factors() %>% 
        
        # рассчитать возраст на момент рандомизации
        mutate(
          age = interval(
            start = date_birth,
            end = datetime_randomization
          ) / dyears()
        ) %>% 
        
        # присвоить лейблы
        set_variable_labels(
          mts_interval = 'Срок метастазирования',
          fong = 'Шкала Fong',
          center = 'Клинический центр',
          mutation = 'Мутационный статус',
          mts_localization = 'Локализация метастаза',
          act_after_oper = 'АХТ после первичного лечения',
          treatment = 'Группа',
          age = 'Возраст',
          .strict = FALSE
        )
      
      # количество пациентов в БД
      stat_list$n_patients <- nrow(data)
      
      # статистика по группе лечения
      stat_list$stat_by_treatment <- data %>% 
        tbl_summary(
          by = treatment,
          include = c(
            age, mts_interval, fong, mutation,
            mts_localization, act_after_oper,
            center
            
          )
        ) %>%
        add_overall(
          last = TRUE,
          col_label = "**Всего**  \nN = {style_number(N)}"
        ) %>% 
        modify_header(label = "**Показатель**") %>% 
        add_p() %>% 
        bold_labels() %>% 
        bold_p() %>% 
        as_gt()
      
      
      # статистика по центрам
      stat_list$stat_by_center <- data %>% 
        tbl_summary(
          by = center,
          include = c(
            age, treatment, mts_interval,
            fong, mutation,
            mts_localization, act_after_oper,
            
          )
        ) %>%
        modify_header(label = "**Показатель**") %>% 
        add_p() %>% 
        bold_labels() %>% 
        bold_p() %>% 
        as_gt()
      
    })
    
    # отрендерить статистику
    output$statUI <- renderUI({
      
      req(
        stat_list$n_patients,
        stat_list$stat_by_center,
        stat_list$stat_by_treatment
      )
      
      tagList(
        
        # количество пациентов в БД
        value_box(
          title = "Пациентов в БД",
          value = stat_list$n_patients,
          showcase = bs_icon('people')
        ),
        
        # статистика по группе лечения
        h2('Статистика по группе лечения'),
        render_gt(stat_list$stat_by_treatment),
        
        # статистика по центру
        h2("Статистика по клиническому центру"),
        render_gt(stat_list$stat_by_center)
      )
    })
    
  })
}