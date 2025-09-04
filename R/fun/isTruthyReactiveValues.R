isTruthyReactiveValues <- function(values) {
  values_list <- reactiveValuesToList(values)
  
  isTruthyListElements <- sapply(values_list, isTruthy)
  
  all(isTruthyListElements)
  
}