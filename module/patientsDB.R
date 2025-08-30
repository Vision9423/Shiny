patientsDBUI <- function(id) {
  DTOutput(
    outputId = NS(namespace = id, id = 'patientsDB')
  )
}


patientsDBServer <- function(id, data) {
  stopifnot(is.reactive(data))
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      
      patientsDB_shiny <- reactive({
        data() %>% 
          get_df_factors() %>% 
          arrange(
            desc(datetime_randomization),
            desc(id)
          )
      })
      
      patientsDB_colnames <- reactive({
        get_ru_colnames(patientsDB_shiny())
      })
      
      output$patientsDB <- renderDT(
        datatable(
          patientsDB_shiny(),
          colnames = patientsDB_colnames(),
          options = list(
            language = list(url = 'https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Russian.json'),
            pageLength = 20
          )
        ) %>% 
          formatDate(
            columns = 'date_birth',
            method = 'toLocaleDateString',
            params = list('ru-RU')
          ) %>% 
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