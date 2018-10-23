# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

#' @export
KeywordsRegistor.run <- function()
{
    library(flowCore)
    library(shiny)
    library(shinydashboard)
    library(shinyjs)


    appDir <- system.file("shinyApp", "app", package = "KeywordsRegistor")
    if (appDir == "")
    {
        stop("Could not find app directory. Try re-installing `KeywordsRegistor`.", call. = FALSE)
    }

    shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}
