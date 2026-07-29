testthat::test_that(
  desc =  "set_dropbox_token() returns a base64 string",
  code = {
    tmp_rds <- tempfile(fileext = ".rds")
    saveRDS(list(a = 1), tmp_rds)
    # it is not a real token, so warning is expected
    testthat::expect_warning(res <- set_dropbox_token(tmp_rds))
    testthat::expect_true(is.character(res))
    testthat::expect_length(res, 1L)
  }
)

testthat::test_that(
  desc = "set_dropbox_token() updates .Renviron",
  code = {
    tmp_rds <- tempfile(fileext = ".rds")
    tmp_env <- tempfile()
    saveRDS(list(a = 1), tmp_rds)
    # it is not a real token, so warning is expected
    testthat::expect_warning(set_dropbox_token(
      token_file = tmp_rds,
      renviron = tmp_env
    ))
    txt <- readLines(
      tmp_env,
      warn = FALSE
    )
    testthat::expect_true(any(grepl("^DROPBOX_TOKEN=", txt)))
  }
)

testthat::test_that(
  desc = "set_dropbox_token() fails for missing file",
  code = {
    testthat::expect_error(set_dropbox_token("does_not_exist.rds"))
  }
)

testthat::test_that(
  desc = "set_app_users() returns json",
  code = {
    users <- data.frame(user = "admin", password = "secret")
    res <- set_app_users(users, renviron = "")
    testthat::expect_true(is.character(res))
    testthat::expect_match(res, "admin")
  }
)

testthat::test_that(
  desc = "set_app_users() can update Renviron",
  code = {
    tmp <- tempfile()
    users <- data.frame(user = "admin", password = "secret")
    set_app_users(users, renviron = tmp)
    x <- readLines(tmp, warn = FALSE)
    testthat::expect_true(any(grepl("^APP_USERS_JSON=", x)))
  }
)

testthat::test_that(
  desc = "set_app_users() validates columns",
  code = {
    users <- data.frame(a = 1)
    testthat::expect_error(set_app_users(users, renviron = ""))
  }
)

testthat::test_that(
  desc = "hashes passwords",
  code = {
    testthat::skip_if_not_installed("sodium")
    users <- data.frame(user = "admin", password = "secret")
    res <- set_app_users(users = users, renviron = "")
    x <- jsonlite::fromJSON(res)
    testthat::expect_false(identical(x$password, "secret"))
    testthat::expect_true(sodium::password_verify(x$password, "secret"))
  }
)
