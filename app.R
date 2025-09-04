library(shiny)
library(bslib)
# library(shinymanager)
# library(shinyFeedback)
# library(shinybusy)
# library(shinyjs)
# 
# library(bsicons)
# library(tidyverse, warn.conflicts = FALSE)
# library(purrr)
# library(Minirand)
# library(DBI)
# library(RMariaDB)
# library(DT)
# library(gt)
# library(gtsummary)
# library(labelled)


# shiny_files <- list.files(
#   path = 'R',
#   pattern = '\\.R$',
#   recursive = TRUE,
#   full.names = TRUE
# )
# 
# lapply(shiny_files, source)
# 
# source('ui.R')
# source('server.R')

ui <- page_navbar(
  title = 'Test',
  nav_panel(
    title = 'Testing',
    'This is nav_panel'
  )
)

server <- function(input, output, session) {}


shinyApp(ui = ui, server = server)