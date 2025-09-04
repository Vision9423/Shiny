get_db <- function(res_auth) {
  
  is_admin <- res_auth$admin == 1
  center <- res_auth$center
  
  con <- connectDB()
  on.exit(if (dbIsValid(con)) dbDisconnect(con), add = TRUE)
  
  if (is_admin) {
    dbReadTable(conn = con, name = "patients")
  } else {
    dbGetQuery(
      conn = con,
      statement = "SELECT * FROM patients WHERE center = ?",
      params = list(center)
    )
  }
}