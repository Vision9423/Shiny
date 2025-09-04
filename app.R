library(shiny)
library(shinymanager)
library(shinyFeedback)
library(shinybusy)
library(shinyjs)
library(bslib)
library(bsicons)
library(tidyverse, warn.conflicts = FALSE)
library(purrr)
library(Minirand)
library(DBI)
library(RMariaDB)
library(DT)
library(gt)
library(gtsummary)
library(labelled)


shiny_files <- list.files(
  path = 'R',
  pattern = '\\.R$',
  recursive = TRUE,
  full.names = TRUE
)

lapply(shiny_files, source)

source('app_ui.R')
source('app_server.R')



shinyApp(ui = ui, server = server)