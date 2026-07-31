# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

golem::document_and_reload()
options( "golem.app.prod" = TRUE)
SimpleUserAuthDropboxApp::run_app() # add parameters here (if any)
