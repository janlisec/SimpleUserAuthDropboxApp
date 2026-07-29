#
#
#
golem::fill_desc(
  pkg_name = "SimpleUserAuthDropboxApp",
  pkg_title = "A Shiny App with partial user access control and dropbox connectivity",
  pkg_description = "This Shiny App is set up as a Golem based R package and provides an open and a restricted tab as well as dropbox connectivity",
  authors = person(
    given = "Jan",
    family = "Lisec",
    email = "jan.lisec@bam.de",
    role = c("aut", "cre")
  ),
  repo_url = NULL,
  pkg_version = "0.0.0.9000",
  set_options = TRUE
)
golem::install_dev_deps()
usethis::use_mit_license("Jan Lisec")
golem::use_readme_rmd(open = FALSE)
devtools::build_readme()
#usethis::use_code_of_conduct(contact = "Golem User")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)
golem::use_recommended_tests()
golem::use_favicon()
golem::use_utils_ui(with_test = TRUE)
golem::use_utils_server(with_test = TRUE)
usethis::use_git()
usethis::use_git_remote(
  name = "origin",
  url = "https://github.com/janlisec/SimpleUserAuthDropboxApp.git"
)
rstudioapi::navigateToFile("dev/02_dev.R")
