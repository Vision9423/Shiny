ui_settings <- tagList(
  # колесо загрузки
  add_busy_spinner(
    spin = 'fulfilling-bouncing-circle',
    color = "#112446",
    position = 'full-page'
  ),
  
  # предупреждения о незаполненных полях
  useShinyFeedback(),
  
  # использовать shinyjs
  useShinyjs()
)