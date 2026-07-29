
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
GitHub and shinyapps.io or Connect Cloud, to get the app working or
using CI tests.

<!-- badges: start -->

<!-- badges: end -->

## Installation

You probably want to clone the repository or download a copy to modify
it to your needs. However, if the Live-App is not sufficient to you and
you want to test the package locally, you can install the development
version of `{SimpleUserAuthDropboxApp}` from GitHub:

``` r
devtools::install_github("janlisec/SimpleUserAuthDropboxApp")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo janlisec/SimpleUserAuthDropboxApp@HEAD
#> cli      (3.6.5 -> 3.6.6) [CRAN]
#> rlang    (1.1.7 -> 1.3.0) [CRAN]
#> magrittr (2.0.4 -> 2.0.5) [CRAN]
#> fs       (1.6.6 -> 2.1.0) [CRAN]
#> glue     (1.8.0 -> 1.8.1) [CRAN]
#> golem    (0.5.1 -> 1.0.1) [CRAN]
#> Installing 6 packages: cli, rlang, magrittr, fs, glue, golem
#> Installiere Pakete nach 'C:/Users/jlisec/AppData/Local/Temp/Rtmp2noXiQ/temp_libpath508c2f6a6439'
#> (da 'lib' nicht spezifiziert)
#> Paket 'cli' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> Paket 'rlang' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> Paket 'magrittr' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> Paket 'fs' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> Paket 'glue' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> Paket 'golem' erfolgreich ausgepackt und MD5 Summen abgeglichen
#> 
#> Die heruntergeladenen Binärpakete sind in 
#>  C:\Users\jlisec\AppData\Local\Temp\RtmpwTG0lA\downloaded_packages
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\jlisec\AppData\Local\Temp\RtmpwTG0lA\remotes584c5ae6635b\janlisec-SimpleUserAuthDropboxApp-4076a98/DESCRIPTION' ...     checking for file 'C:\Users\jlisec\AppData\Local\Temp\RtmpwTG0lA\remotes584c5ae6635b\janlisec-SimpleUserAuthDropboxApp-4076a98/DESCRIPTION' ...   ✔  checking for file 'C:\Users\jlisec\AppData\Local\Temp\RtmpwTG0lA\remotes584c5ae6635b\janlisec-SimpleUserAuthDropboxApp-4076a98/DESCRIPTION' (861ms)
#>       ─  preparing 'SimpleUserAuthDropboxApp': (415ms)
#>      checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts (945ms)
#>   ─  checking for empty or unneeded directories
#>      Omitted 'LazyData' from DESCRIPTION
#>       ─  building 'SimpleUserAuthDropboxApp_0.0.0.9000.tar.gz'
#>      
#> 
#> Installiere Paket nach 'C:/Users/jlisec/AppData/Local/Temp/Rtmp2noXiQ/temp_libpath508c2f6a6439'
#> (da 'lib' nicht spezifiziert)
```

## Run

Before launching the app locally you need to set up information
regarding the user list and your dropbox token in the local .Renviron
file. You can use the package convenience functions to achieve this.

``` r
library(SimpleUserAuthDropboxApp)
# will open an authentication dialog for your dropbox (you should have an account)
set_dropbox_token()
# will set up a user 'test' with password 'test'. Please note: passwords get hashed 
# in .Renviron
set_app_users(users = data.frame(user = "test", password = "test"))
# check if .Renviron of the local package was created and modified
readLines(".Renviron")
# now re-start R (new session to load the modified .Renviron)
#...

# now start the app locally to test...
run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2026-07-29 13:15:21 CEST"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading SimpleUserAuthDropboxApp
#> ── R CMD check results ──────────────── SimpleUserAuthDropboxApp 0.0.0.9000 ────
#> Duration: 2m 0.2s
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> 0 errors ✔ | 0 warnings ✔ | 1 note ✖
```

``` r
covr::package_coverage()
#> Error in `loadNamespace()`:
#> ! es gibt kein Paket namens 'covr'
```
