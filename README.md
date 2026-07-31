
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{SimpleUserAuthDropboxApp}`

This is a R-package template containing a Shiny-App (with golem
framework) that integrates user management and dropbox authentification.
Check the Live-App demo provided to get the idea.

I created this as a reminder to myself how to store user information and
account secrets in a public GitRepo, containing a R-package, containing
a Shiny-App… in an appropriate way.

This template allows you to store your dropbox account information and
user names and passwords in a local .Renviron file within your package.
You can provide this information in a safe way (as a secret) to both,
GitHub and shinyapps.io/ Connect Cloud, to get the app working or using
CI tests.

<!-- badges: start -->

[![Static
Badge](https://img.shields.io/badge/LiveApp-blue)](https://jali-simpleuserauthdropboxapp.share.connect.posit.cloud/)
<!-- badges: end -->

## Installation

You probably want to clone the repository or download a copy to modify
it to your needs. However, if the Live-App is not sufficient to you and
you want to test the package locally, you can install the development
version of `{SimpleUserAuthDropboxApp}` from GitHub:

## Run

Before launching the app locally you need to set up information
regarding the user list and your dropbox token in the local .Renviron
file. You can use two package convenience functions to achieve this.

``` r
library(SimpleUserAuthDropboxApp)

# will open an authentication dialog for your dropbox (you should have an account)
# it will write the token information in the local .Renviron file. Ensure that
# this always remains enlisted in the .gitignore
set_dropbox_token()

# will set up a user 'test' with password 'test' and store this as a json string
# in .Renviron file. Please note: passwords get hashed as a standard.
set_app_users(users = data.frame(user = "test", password = "test"))

# check if .Renviron of the local package was created and modified
readLines(".Renviron")

# now re-start R (you need a new session to load the modified .Renviron)
#...

# now start the app locally to test...
run_app()
```

## About

You are reading the doc about version : 0.0.0.9000 compiled at
`{r Sys.time()}`.

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading SimpleUserAuthDropboxApp
#> ── R CMD check results ──────────────── SimpleUserAuthDropboxApp 0.0.0.9000 ────
#> Duration: 1m 5.1s
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namensraum im Imports Feld nicht importiert aus: 'desc'
#>     All declared Imports should be used.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 1 note ✖
```

``` r
covr::package_coverage()
#> SimpleUserAuthDropboxApp Coverage: 36.26%
#> R/app_config.R: 0.00%
#> R/app_server.R: 0.00%
#> R/app_ui.R: 0.00%
#> R/run_app.R: 0.00%
#> R/app_utils.R: 59.62%
```
