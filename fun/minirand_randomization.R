library(dplyr)

patients <- tibble(
  name = c('Пациент 1', 'Пациент 2', 'Пациент 3', 'Пациент 4'),
  mts_interval = c(1, 1, 1, 0),
  fong = c(0, 1, 1, 1),
  center = c(0, 3, 3, 0),
  mutation = c(0, 0, 0, 1),
  mts_localization = c(0, 1, 0, 0),
  act_after_oper = c(1, 1, 0, 0)
)


Minirand(
  covmat = patients,
  j = 3,
  covwt = rep(x = 1/6, times = 6),
  ratio = c(1, 1),
  ntrt = 2,
  trtseq = c(0, 1),
  method = 'Range',
  result = c(0, 0),
  p = 0.9
)