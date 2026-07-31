#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    golem_add_external_resources(),
    shiny::fluidPage(
      shiny::tabsetPanel(
        shiny::tabPanel(
          "Public",
          shiny::h3("Public content"),
          shiny::p("This could contain any public shiny inputs and outputs."),
          shiny::p("Switch to tab 'Protected'...")
        ),
        shiny::tabPanel(
          "Protected",
          shiny::p("You can log in with user = test, password = test."),
          shiny::p("If it works as expected you will see 2 outputs defining the login user name and the dropbox account name..."),
          shiny::uiOutput("protected_ui")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @noRd
golem_add_external_resources <- function() {
  golem::add_resource_path("www", app_sys("app/www"))
  shiny::tags$head(
    golem::favicon(),
    golem::bundle_resources(path = app_sys("app/www"), app_title = "SimpleUserAuthDropboxApp")
  )
}
