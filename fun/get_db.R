get_db <- function(admin, center) {
  con <- connectDB()
  on.exit(if (dbIsValid(con)) dbDisconnect(con), add = TRUE)
  
  if (admin == 1) {
    dbReadTable(conn = con, name = "patients")
  } else {
    dbGetQuery(
      conn = con,
      statement = "SELECT * FROM patients WHERE center = ?",
      params = list(center)
    )
  }
}