#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  authenticated <- shiny::reactiveVal(FALSE)
  current_user <- shiny::reactiveVal(NULL)
  observeEvent(input$login_btn, {
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
    tool_a_ui("tool")
  })

  tool_a_server("tool", current_user = current_user)
}
