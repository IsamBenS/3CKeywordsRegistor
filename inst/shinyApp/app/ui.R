library(shiny)
library(shinydashboard)
library(shinyjs)

ui <- dashboardPage(
    
    dashboardHeader
    (
        title="Keywords Registor"
    ),
    
    dashboardSidebar
    (
        sidebarMenu
        (
            id="tabs",
            useShinyjs(),
            actionButton("files_sel", "Select File", width = "88%"),
            box
            (
                width=12, style="padding-left:17%",
                downloadButton("files_dl", "Download File")
            )
        )
    ),
    
    dashboardBody
    (
        useShinyjs(),
        tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
        fluidRow
        (
            id="main_fr",
            box
            (
                id="registered_analyses_box", collapsible = T, width=5, style="padding-right:4%",title="Registered Analyses", 
                fluidRow
                (
                    id="registered_analyses_fr"
                )
            ),
            box
            (
                id="new_analysis_box", collapsible = T, width=7, style="padding-right:4%",title="Register New Analysis", 
                fluidRow
                (
                    id="new_analysis_fr",
                    box
                    (
                        width=12,
                        box
                        (
                            width = 8, style="height:8vh",
                            textInput("new_analysis_name", "Analysis Name")
                        ),
                        actionButton("new_analysis_save_button", "Register",
                                     style="height:4vh;margin-top:2%;width:25%;margin-left:5%"),
                        box
                        (
                            width = 6,
                            selectInput("new_analysis_column", "Select file column", choices=NULL, selected = NULL)
                        ),
                        box
                        (
                            width = 6,
                            selectInput("new_analysis_markers", "Select markers", multiple=T, choices=NULL, selected = NULL)
                        ),
                        box
                        (
                            collapsible = T, width=8, style="padding-right:2%", title="Parameters", id="new_analysis_parameters"
                        ),
                        box
                        (
                            width=4,style="padding-left:5%",
                            actionButton("new_analysis_add_param_button", "Add Parameter", width = "90%")
                        )
                    )
                )
            )
        )
    )
    
)