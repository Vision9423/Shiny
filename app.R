library(shiny)

ui <- fluidPage(
  title = 'Test',
  verbatimTextOutput('test')
)
server <- function(input, output, session) {
  
  test <- list(
    host = Sys.getenv('db_host'),
    port = Sys.getenv('db_port'),
    dbname = Sys.getenv('db_dbname'),
    user = Sys.getenv('db_user'),
    password = Sys.getenv('db_password')
  )
  
  
  output$test <- renderPrint(test)
  
}

shinyApp(ui = ui, server = server)