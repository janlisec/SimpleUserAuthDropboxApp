# auth helpers -------------------------------------------------------------

#' Read users from env
#'
#' @return data.frame
#'
#' @noRd
#' @keywords internal
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
#' @noRd
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   validate_user("test", "test")
#' }
validate_user <- function(user, password) {
  users <- read_users()
  hit <- which(users$user == user)
  if (length(hit) != 1L) { return(FALSE) }
  stored <- users$password[hit]
  if (requireNamespace("sodium", quietly = TRUE) && grepl("^\\$7\\$", stored)) {
    return(sodium::password_verify(hash = stored, password = password))
  }
  identical(stored, password)
}

#' Get Dropbox token
#'
#' @return character(1)
#'
#' @noRd
#' @keywords internal
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

#' Update .Renvir value for specific key
#'
#' @param key key.
#' @param val, value.
#' @param renviron Path to .Renviron.
#'
#' @return character(1)
#'
#' @noRd
#' @keywords internal
update_Renvir_value <- function(key, val, renviron = ".Renviron") {
  if (!file.exists(renviron)) { file.create(renviron) }
  lines <- readLines(renviron, warn = FALSE)
  x <- paste0(key, "='", val, "'")
  hit <- grepl(paste0("^", gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", key), "="), lines)
  if (any(hit)) {
    lines[hit] <- x
  } else {
    lines <- c(lines, x)
  }
  writeLines(lines, renviron)
}

#' Prepare Dropbox token for environment variable
#'
#' Reads a token.rds, validates it and converts it to a
#' base64 string suitable for DROPBOX_TOKEN.
#'
#' @param token_file Path to token.rds. If not provided, `rdrop2::drop_auth()`
#'     is called to generate a valid rds file for the current user.
#' @param renviron Path to .Renviron. If empty string is provided than only the
#'     token is returned (no file modified).
#' @return Character scalar.
#'
#' @examples
#' \dontrun{
#'   set_dropbox_token(
#'     "token.rds",
#'     update_renviron = TRUE
#'   )
#' }
#' @export
set_dropbox_token <- function(token_file = NULL, renviron = ".Renviron") {
  if (is.null(token_file)) {
    token <- rdrop2::drop_auth()
    token_file <- tempfile(fileext = ".rds")
    saveRDS(token, token_file)
  }
  stopifnot(is.character(token_file), length(token_file) == 1L)
  if (!file.exists(token_file)) { stop("token_file does not exist") }
  token <- readRDS(token_file)
  ok <- inherits(token, "Token2.0") || inherits(token, "TokenDropbox")
  if (!ok) { warning("Object is not a recognised Dropbox token") }
  raw <- readBin(token_file, what = "raw", n = file.info(token_file)$size)
  val <- openssl::base64_encode(raw)
  if (nzchar(renviron)) update_Renvir_value(key = "DROPBOX_TOKEN", val = val, renviron = renviron)
  return(val)
}

#' Set app users
#'
#' Store users as JSON in APP_USERS_JSON.
#' Passwords can optionally be hashed using sodium.
#'
#' @param users Data frame with columns user and password.
#' @param hash_passwords Logical.
#' @param renviron Path to .Renviron. Empty string disables file update.
#'
#' @return Character scalar.
#'
#' @examples
#' users <- data.frame(
#'   user = c("admin", "jan"),
#'   password = c("secret", "geheim")
#' )
#'
#' set_app_users(
#'   users = users,
#'   hash_passwords = FALSE,
#'   renviron = ""
#' )
#' @export
set_app_users <- function(
    users,
    hash_passwords = TRUE,
    renviron = ".Renviron"
) {
  stopifnot(is.data.frame(users))
  required <- c("user", "password")
  if (!all(required %in% names(users))) {
    stop("users must contain columns: ", paste(required, collapse = ", "))
  }
  users <- users[, required]
  if (isTRUE(hash_passwords)) {
    if (!requireNamespace("sodium", quietly = TRUE)) {
      stop("Package 'sodium' required when hash_passwords = TRUE")
    }
    users$password <- vapply(
      users$password,
      FUN.VALUE = character(1),
      FUN = sodium::password_store
    )
  }
  val <- jsonlite::toJSON(users, dataframe = "rows", auto_unbox = TRUE)
  if (nzchar(renviron)) {
    update_Renvir_value(key = "APP_USERS_JSON", val = val, renviron = renviron)
  }
  return(val)
}

# tool module --------------------------------------------------------------

#' @noRd
#' @keywords internal
protected_tab_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h3("Protected Tool"),
    shiny::verbatimTextOutput(ns("user")),
    shiny::verbatimTextOutput(ns("dropbox"))
  )
}

#' @noRd
#' @keywords internal
protected_tab_server <- function(id, current_user) {
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
