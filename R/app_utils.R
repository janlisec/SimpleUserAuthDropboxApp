# auth helpers -------------------------------------------------------------

#' Read users from env
#'
#' @return data.frame
#'
#' @examples
#' \dontrun{
#'   read_users()
#' }
read_users <- function() {
  json <- Sys.getenv("APP_USERS_JSON")
  if (!nzchar(json)) {
    stop("APP_USERS_JSON missing")
  }
  return(jsonlite::fromJSON(json))
}

#' Validate credentials
#'
#' @param user Username
#' @param password Password
#'
#' @return logical
#'
#' @examples
#' \dontrun{
#'   validate_user("admin", "secret")
#' }
validate_user <- function(user, password) {
  users <- read_users()
  any(users$user == user & users$password == password)
}

#' Get Dropbox token
#'
#' @return character(1)
#'
#' @examples
#' \dontrun{
#'   get_dropbox_token()
#' }
get_dropbox_token <- function() {
  if (!is.na(Sys.getenv("DROPBOX_TOKEN", unset = NA_character_))) {
    token_b64 <- Sys.getenv("DROPBOX_TOKEN", unset = NA_character_)
    if (nzchar(token_b64)) {
      token_file <- normalizePath(file.path(tempdir(), "token.rds"), mustWork = FALSE)
      raw <- tryCatch(openssl::base64_decode(token_b64), error = function(e) NULL)
      if (!is.null(raw)) {
        writeBin(raw, token_file)
      }
    }
    #inherits(rdrop2::drop_auth(rdstoken = token_file), "Token2.0")
  } else {
    warning("token.rds not available")
  }
  return(token_file)
}

# tool module --------------------------------------------------------------

tool_a_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h3("Protected Tool"),
    shiny::verbatimTextOutput(ns("user")),
    shiny::verbatimTextOutput(ns("dropbox"))
  )
}

tool_a_server <- function(id, current_user) {
  shiny::moduleServer(id, function(input, output, session) {
      output$user <- shiny::renderText({
        paste("Logged in as:", current_user())
      })
      output$dropbox <- shiny::renderText({
        token <- get_dropbox_token()
        rdrop2::drop_auth(rdstoken = token)
        res <- tryCatch({
            acc <- rdrop2::drop_acc()
            paste("Dropbox OK:", acc$name$display_name)
          },
          error = function(e) { paste("Dropbox error:", e$message) }
        )
        res
      })
    }
  )
}
