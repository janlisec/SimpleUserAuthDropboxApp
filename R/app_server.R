#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
app_server <- function(input, output, session) {

  authenticated <- shiny::reactiveVal(FALSE)
  current_user <- shiny::reactiveVal(NULL)
  shiny::observeEvent(input$login_btn, {
    ok <- validate_user(
      user = input$user,
      password = input$password
    )
    if (ok) {
      authenticated(TRUE)
      current_user(input$user)
    }
  })

  output$protected_ui <- shiny::renderUI({
    if (!authenticated()) {
      return(
        shiny::tagList(
          shiny::textInput("user", "User"),
          shiny::passwordInput("password", "Password"),
          shiny::actionButton("login_btn", "Login")
        )
      )
    }
    protected_tab_ui("tool")
  })

  protected_tab_server("tool", current_user = current_user)
}
