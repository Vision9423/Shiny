patientsDBUI <- function(id) {
  DTOutput(
    outputId = NS(namespace = id, id = 'patientsDB')
  )
}


patientsDBServer <- function(id, data, res_auth) {
  stopifnot(is.reactive(data))
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      
      patientsDB_shiny <- reactive({
        
        req(data())
        
        shiny_data <- data() %>% 
          # преобразовать числовые данные в факторы
          get_df_factors() %>% 
          
          # номер в порядке добавления
          mutate(patient_num = row_number()) %>% 
          
          # номер в порядке добавления в своем клиническом центре
          group_by(center) %>% 
          mutate(patient_num_center = row_number()) %>% 
          ungroup() %>% 
          
          # сортировать по дате рандомизации
          arrange(
            desc(datetime_randomization),
            desc(id)
          ) %>% 
          
          # упорядочить столбцы
          relocate(
            patient_num, patient_num_center,
            .after = id
          )
        
        # если нет прав администратора, то скрыть столбцы с ID
        # и общей нумерацией
        if (res_auth$admin != 1) {
          shiny_data <- shiny_data %>% 
            select(-c(id, patient_num))
        }
        
        shiny_data
      })
      
      patientsDB_colnames <- reactive({
        get_ru_colnames(patientsDB_shiny())
      })
      
      output$patientsDB <- renderDT(
        datatable(
          patientsDB_shiny(),
          colnames = patientsDB_colnames(),
          width = '300px',
          filter = 'top', # включить возможность фильтрации
          options = list(
            
            # русский язык
            language = list(
              url = 'https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Russian.json'
            ),
            
            # количество строк по умолчанию
            pageLength = 10,
            
            # настроить какие столбцы можно фильтровать
            columnDefs = list(
              list(
                targets = c(
                  'name', 'mts_interval', 'fong', 'center',
                  'mutation', 'mts_localization', 'act_after_oper',
                  'treatment'
                ),
                searchable = TRUE
              ),
              list(targets = "_all", searchable = FALSE)
            )
          )
        ) %>% 
          
          # русский формат даты для даты рождения
          formatDate(
            columns = 'date_birth',
            method = 'toLocaleDateString',
            params = list('ru-RU')
          ) %>% 
          
          # русский формат даты и времени для даты и времени рандомизации
          formatDate(
            columns = 'datetime_randomization',
            method = 'toLocaleString',
            params = list(
              'ru-RU', 
              list(timeZone = 'Europe/Moscow', hour12 = FALSE)
            )
          )
      )
      
    }
  )
}