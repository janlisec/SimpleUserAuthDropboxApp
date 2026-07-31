# auth helpers ----

#' Read users from env
#'
#' @return data.frame
#'
#' @examples
#' \dontrun{
#'   read_users()
#' }
#'
#' @noRd
#' @keywords internal
#'
read_users <- function() {
  json <- read_env_value("APP_USERS_JSON")
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
#'   validate_user("test", "test")
#' }
#'
#' @noRd
#' @keywords internal
#'
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

#' Split string into chunks
#'
#' @param x Character scalar.
#' @param chunk_size Maximum chunk length.
#'
#' @return Character vector.
#'
#' @examples
#' split_string("abcdef", chunk_size = 2)
#'
#' @noRd
#' @keywords internal
#'
split_string <- function(x, chunk_size = 4000L) {
  stopifnot(is.character(x), length(x) == 1L)
  n <- nchar(x)
  starts <- seq.int(from = 1L, to = n, by = chunk_size)
  vapply(starts, function(i) {
    substr(x, i, min(i + chunk_size - 1L, n))
    }, character(1)
  )
}

#' Get Dropbox token
#'
#' @return character(1)
#'
#' @examples
#' \dontrun{
#'   token_file <- get_dropbox_token()
#'   inherits(readRDS(token_file), "Token2.0")
#' }
#'
#' @noRd
#' @keywords internal
#'
get_dropbox_token <- function() {
  token_b64 <- read_env_value("DROPBOX_TOKEN")
  if (nzchar(token_b64)) {
    token_file <- normalizePath(file.path(tempdir(), "token.rds"), mustWork = FALSE)
    raw <- tryCatch(openssl::base64_decode(token_b64), error = function(e) NULL)
    if (!is.null(raw)) {
      writeBin(raw, token_file)
    }
  } else {
    stop("DROPBOX_TOKEN not configured.")
  }
  return(token_file)
}

#' Update .Renviron value
#'
#' Write a value to .Renviron.
#' Long values are split into numbered entries.
#'
#' @param key Variable name.
#' @param val Variable value.
#' @param renviron Path to .Renviron.
#'
#' @return Invisible NULL.
#'
#' @examples
#' tmp <- tempfile()
#' SimpleUserAuthDropboxApp:::update_Renvir_value(key = "TEST", val = "abc", renviron = tmp)
#' readLines(tmp)
#'
#' @noRd
#' @keywords internal
#'
update_Renvir_value <- function(key, val, renviron = ".Renviron") {
  nchar_lim <- 4000L
  if (!file.exists(renviron)) { file.create(renviron) }
  lines <- readLines(renviron, warn = FALSE)
  # remove key and all split keys
  pattern <- paste0("^", key, "(_[0-9]+)?=")
  lines <- lines[!grepl(pattern, lines)]
  if (nchar(val) <= nchar_lim) {
    lines <- c(lines, paste0(key, "='", val, "'"))
  } else {
    parts <- split_string(val, chunk_size = nchar_lim)
    lines <- c(lines, paste0(key, "_", seq_along(parts), "='", parts, "'"))
  }
  writeLines(lines, renviron)
  invisible(NULL)
}

#' Read value from .Renviron or environment
#'
#' @param key Variable name.
#'
#' @return Character scalar.
#'
#' @examples
#' \dontrun{
#' read_env_value("DROPBOX_TOKEN")
#' }
#'
#' @noRd
#' @keywords internal
#'
read_env_value <- function(key) {
  val <- Sys.getenv(key, unset = "")
  if (nzchar(val)) { return(val) }
  parts <- character()
  i <- 1L
  repeat {
    part <- Sys.getenv(paste0(key, "_", i), unset = "")
    if (!nzchar(part)) { break }
    parts <- c(parts, part)
    i <- i + 1L
  }
  if (!length(parts)) {
    return("")
  }
  paste0(parts, collapse = "")
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
#'   x <- set_dropbox_token()
#' }
#' @export
set_dropbox_token <- function(token_file = NULL, renviron = ".Renviron") {
  if (is.null(token_file)) {
    token <- rdrop2::drop_auth()
    if (inherits(token, "Token2.0")) {
      token_file <- tempfile(fileext = ".rds")
      saveRDS(token, token_file)
    }
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
#'   user = c("admin", "test"),
#'   password = c("secret", "test")
#' )
#'
#' set_app_users(users = users, hash_passwords = FALSE, renviron = "")
#' set_app_users(users = users, hash_passwords = TRUE, renviron = "")
#' \dontrun{
#'   set_app_users(users = users, renviron = ".Renviron")
#' }
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
        paste("Logged in as user:", current_user())
      })
      output$dropbox <- shiny::renderText({
        token <- get_dropbox_token()
        rdrop2::drop_auth(rdstoken = token)
        res <- tryCatch({
            acc <- rdrop2::drop_acc()
            paste("Dropbox account name:", acc$name$display_name)
          },
          error = function(e) { paste("Dropbox error:", e$message) }
        )
        res
      })
    }
  )
}
