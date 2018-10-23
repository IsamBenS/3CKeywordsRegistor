library(shiny)
library(shinydashboard)
library(flowCore)
library(shinyjs)

server <- function(input, output, session)
{
    useShinyjs()
    #======================================================================================================================
    #======================REACTIVE VALUES=================================================================================
    #======================================================================================================================
    
    global.values <- reactiveValues(
        fcs.files = NULL,
        fcs.files.ui.colnames = NULL,
        modified.files = NULL,
        analyses.parameters = NULL
    )
    
    write.enriched.FCS <- function(fcs, fcs.path)
    {
        keywords.to.save <- names(get.keywords.with.keypart.FCS(fcs, "MAPOP_pop_label"))
        keywords.to.save <- c(unlist(keywords.to.save), names(get.keywords.with.keypart.FCS(fcs, "EXPPUR__")))
        keywords.to.save <- c(unlist(keywords.to.save), names(get.keywords.with.keypart.FCS(fcs, "RF_pop_label")))
        keywords.to.save <- c(unlist(keywords.to.save), names(get.keywords.with.keypart.FCS(fcs, "CLMETH__")))
        
        write.FCS.CIPHE(fcs,fcs.path, keywords.to.save = keywords.to.save)
    }
    
    
    
    
    
    
    #======================================================================================================================
    #======================================================================================================================
    #==========================================LOAD FILES==================================================================
    #======================================================================================================================
    
    observe(#ACTIVATE/DISABLE UI
    {
        if((length(global.values$fcs.files) > 0)  && is.defined(global.values$fcs.files[[1]]))
        {
            shinyjs::enable("files_dl")
            shinyjs::enable("new_analysis_add_param_button")
            if(is.defined(input$new_analysis_name) && input$new_analysis_name != "" && input$new_analysis_name != " ")
            {
                shinyjs::enable("new_analysis_save_button")
            }
            else
            {
                shinyjs::disable("new_analysis_save_button")
            }
        }
        else
        {
            shinyjs::disable("files_dl")
            shinyjs::disable("new_analysis_add_param_button")
            shinyjs::disable("new_analysis_save_button")
        }
    })
    
    observeEvent(input$files_sel,#LOAD FILES
    {
         shinyjs::disable("files_sel")
         progress.bar <- Progress$new()
         progress.bar$set(message="LOADING FILE", value = 0)
         on.exit(progress.bar$close())
         m <- matrix(nrow=1,ncol=2)
         m[1,1] = "FlowFrames"
         m[1,2] = "*.csv;*.fcs"
         temp.files <- choose.files(filters = m,multi = F)
         
         nx <- list()
         if(length(temp.files) != 0)
         {
             lapply(temp.files, function(f)
             {
                 l <- length(f)
                 x <- NULL
                 if(grepl("csv",f))
                 {
                     x <- as.matrix(read.csv(f))
                     x <- flowFrame(x)
                     for(i in 1:ncol(x@exprs))
                     {
                         d <- x@description[[paste0("$P",i,"S")]]
                         if(is.null(d) || is.na(d) || d == "" || d == " " || d == "NA" || d == "<NA>" || d == "'<NA>'")
                         {
                             d <- colnames(x)[i]
                         }
                         nx[[i]] <<- d
                     }
                     
                 }
                 else
                 {
                     x <- read.FCS(f,emptyValue = FALSE)
                     for(i in 1:ncol(x@exprs))
                     {
                         d <- x@description[[paste0("$P",i,"S")]]
                         if(is.null(d) || is.na(d) || d == "" || d == " " || d == "NA" || d == "<NA>" || d == "'<NA>'")
                         {
                             d <- colnames(x)[i]
                         }
                         nx[[i]] <<- d
                     }
                 }
                 global.values$fcs.files <- list()
                 global.values$fcs.files.ui.colnames <- list()
                 
                 fcs.name <- paste0(basename(substr(f,1,nchar(f)-4)), "___",as.integer(Sys.time()))
                 
                 global.values$fcs.files[[1]] <<- x
                 global.values$fcs.files.ui.colnames[[1]] <<- nx
                 names(global.values$fcs.files)[1] <<- fcs.name
                 names(global.values$fcs.files.ui.colnames)[1] <<- fcs.name
                 global.values$modified.files[[1]] <<- T
                 
                 progress.bar$inc(1/length(temp.files), detail=paste0("File ", f, " loaded"))
             })
         }
         
         shinyjs::delay(500,
         {
             shinyjs::enable("files_sel")
             shinyjs::enable("files_dl")
         })
         progress.bar$set(message="Done", value = 1)
         
    })
    
    observe(#LOAD FILES INFORMATION
    {
        if(length(global.values$fcs.files)>0)
        {
            lapply(1:length(global.values$fcs.files), function(f)
            {
                fcs <- global.values$fcs.files[[f]]
                if(is.defined(fcs))
                {
                    idf <- names(global.values$fcs.files)[f]
                    
                    #POP COL LOADING---------------------
                    pop.col.sel <- 1:ncol(fcs@exprs)
                    names(pop.col.sel) <- lapply(1:ncol(fcs@exprs), function(j)
                    {
                        d <- fcs@description[[paste0("$P",j,"S")]]
                        if(is.null(d) || !is.na(d) || d != "" || d != " ")
                        {
                            d <- global.values$fcs.files.ui.colnames[[f]][[j]]
                        }
                        names(d) <- NULL
                        
                        return(unlist(d))
                    })
                    map.col.sel <- NULL
                    curr.file.label <- list()
                    if(keyword.exists.FCS(fcs,"RF_pop_label"))
                    {
                        curr.file.label <- as.numeric(get.keywords.with.keypart.FCS(fcs,"RF_pop_label")[[1]][[1]])
                    }
                    
                    #UI CREATION------------------------
                    if(global.values$modified.files[[f]])
                    {
                        removeUI(paste0("#registered_analyses",f))
                        insertUI("#registered_analyses_fr",
                                 "beforeEnd",
                                 fluidRow
                                 (
                                     style="margin-left:1.7vw",id=paste0("registered_analyses",f),
                                     box
                                     (
                                         width= 12,
                                         fluidRow
                                         (
                                             id=paste0("registered_analyses_list")
                                         )
                                     )
                                )
                        )
                    }
                    
                    #PREVIOUS ANALYSES LOADING---------------------------
                    if(global.values$modified.files[[f]])
                    {
                        previous.analyses <- FPH.retrieve.clusters.data.from.file(fcs)
                        prev.an.algo <- previous.analyses[[1]]
                        if(is.defined(prev.an.algo))
                        { 
                            lapply(1:length(prev.an.algo), function(k)
                            {
                                curr.algorithms <- prev.an.algo[[k]]
                                
                                if(is.defined(curr.algorithms))
                                {
                                    available.runs <- 1:length(curr.algorithms)
                                    for(current.algo.run.id in 1:length(curr.algorithms))
                                    {
                                        current.algo.run <- curr.algorithms[[current.algo.run.id]]
                                        tmp.run.name <- ""
                                        tmp.run.parameters <- extract.run.parameters(current.algo.run)
                                        if(length(tmp.run.parameters)>0)
                                        {
                                            for(par.id in 1:length(tmp.run.parameters))
                                            {
                                                tmp.run.name <- paste0(tmp.run.name, 
                                                                       names(tmp.run.parameters)[par.id], "=", tmp.run.parameters[[par.id]], ", ")
                                            }
                                        }
                                        names(available.runs)[current.algo.run.id] <- tmp.run.name
                                    }
                                    
                                    insertUI(paste0("#registered_analyses_list"),
                                             "beforeEnd",
                                             box
                                             (
                                                 id=paste0("t_1_3_",f,"_2_b_",k), width=12,
                                                 collapsible=T, title=names(prev.an.algo)[k],
                                                 selectInput(paste0("t_1_3_",f,"_2_b_",k,"_run"),"Select analysis",choices = available.runs),
                                                 box
                                                 (
                                                     title = "Markers",id=paste0("t_1_3_",f,"_2_b_",k,"_mark"),style="height:17vh;overflow:auto",
                                                     div
                                                     (
                                                         id=paste0("t_1_3_",f,"_2_b_",k,"_mark_content") 
                                                     )
                                                 ),
                                                 box
                                                 (
                                                     title = "Parameters",id=paste0("t_1_3_",f,"_2_b_",k,"_param"),style="height:17vh;overflow:auto",
                                                     div
                                                     (
                                                         id=paste0("t_1_3_",f,"_2_b_",k,"_param_content")
                                                     )
                                                 )
                                             )
                                    )
                                }
                            })
                        }
                    }
                }
            })
        }
    })
    
    observe(#LOAD PREVIOUS ANALYSES - CONTENT
    {
        if(length(global.values$fcs.files)>0)
        {
            lapply(1:length(global.values$fcs.files), function(f)
            {
                fcs <- global.values$fcs.files[[f]]
                if(is.defined(fcs))
                {
                    idf <- names(global.values$fcs.files)[f]
                    
                    #POP COL LOADING---------------------
                    pop.col.sel <- 1:ncol(fcs@exprs)
                    names(pop.col.sel) <- lapply(1:ncol(fcs@exprs), function(j)
                    {
                        d <- fcs@description[[paste0("$P",j,"S")]]
                        if(is.null(d) || !is.na(d) || d != "" || d != " ")
                        {
                            d <- global.values$fcs.files.ui.colnames[[f]][[j]]
                        }
                        names(d) <- NULL
                        
                        return(unlist(d))
                    })
                    
                    
                    #PREVIOUS ANALYSES LOADING---------------------------
                    previous.analyses <- FPH.retrieve.clusters.data.from.file(fcs)
                    prev.an.algo <- previous.analyses[[1]]
                    prev.an.markers <- previous.analyses[[2]]
                    prev.an.param <- previous.analyses[[3]]
                    if(!is.null(prev.an.algo))
                    {
                        lapply(1:length(prev.an.algo), function(k)
                        {
                            curr.algorithms <- prev.an.algo[[k]]
                            curr.parameters <- prev.an.param[[k]]
                            curr.markers <- prev.an.markers[[k]]
                            
                            if(!is.null(curr.algorithms))
                            {
                                run.choices <- 1:length(curr.algorithms)
                                names(run.choices) <- curr.algorithms
                                
                                if(is.defined(input[[paste0("t_1_3_",f,"_2_b_",k,"_run")]]) && 
                                   input[[paste0("t_1_3_",f,"_2_b_",k,"_run")]] != "" && 
                                   input[[paste0("t_1_3_",f,"_2_b_",k,"_run")]] != " ")
                                {
                                    l <- as.numeric(input[[paste0("t_1_3_",f,"_2_b_",k,"_run")]])
                                    
                                    removeUI(paste0("#t_1_3_",f,"_2_b_",k,"_mark_content"))
                                    insertUI(paste0("#t_1_3_",f,"_2_b_",k,"_mark"),
                                             "beforeEnd",
                                             div(id=paste0("t_1_3_",f,"_2_b_",k,"_mark_content")))
                                    
                                    removeUI(paste0("#t_1_3_",f,"_2_b_",k,"_param_content"))
                                    insertUI(paste0("#t_1_3_",f,"_2_b_",k,"_param"),
                                             "beforeEnd",
                                             div(id=paste0("t_1_3_",f,"_2_b_",k,"_param_content")))
                                    
                                    if(length(curr.markers[[l]])>0 && curr.markers[[l]][[1]] != "NULL")
                                    {
                                        lapply(1:length(curr.markers[[l]]), function(m)
                                        {
                                            insertUI(paste0("#t_1_3_",f,"_2_b_",k,"_mark_content"),
                                                     "beforeEnd",
                                                     h5(names(pop.col.sel)[[as.integer(curr.markers[[l]][m])]])
                                            )
                                        })
                                    }
                                    
                                    if(!is.null(curr.parameters[[l]]))
                                    {
                                        lapply(1:length(curr.parameters[[l]]), function(m)
                                        {
                                            par.name <- strsplit(curr.parameters[[l]][m],"-")[[1]][1]
                                            par.val <- strsplit(curr.parameters[[l]][m],"-")[[1]][2]
                                            insertUI(paste0("#t_1_3_",f,"_2_b_",k,"_param_content"),
                                                     "beforeEnd",
                                                     h5(paste0(par.name,": ",par.val))
                                            )
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
    })
    
    observe(#NEW ANALYSIS - COLUMN SELECTION
    {
        if(length(global.values$fcs.files)>0)
        {
            lapply(1:length(global.values$fcs.files), function(f)
            {
                fcs <- global.values$fcs.files[[f]]
                if(is.defined(fcs))
                {
                    idf <- names(global.values$fcs.files)[f]
                    
                    #COLUMNS LISTING---------------------
                    analysis.column <- 1:ncol(fcs@exprs)
                    names(analysis.column) <- lapply(1:ncol(fcs@exprs), function(j)
                    {
                        d <- fcs@description[[paste0("$P",j,"S")]]
                        if(is.null(d) || !is.na(d) || d != "" || d != " ")
                        {
                            d <- global.values$fcs.files.ui.colnames[[f]][[j]]
                        }
                        names(d) <- NULL
                        
                        return(unlist(d))
                    })
                    updateSelectInput(session, "new_analysis_column", label = "Select clusters column", choices=analysis.column, selected = NULL)
                }
            })
        }
    })
    
    observe(#NEW ANALYSIS - MARKERS SELECTION
    {
        if(length(global.values$fcs.files)>0)
        {
            lapply(1:length(global.values$fcs.files), function(f)
            {
                fcs <- global.values$fcs.files[[f]]
                if(is.defined(fcs))
                {
                    idf <- names(global.values$fcs.files)[f]
                    
                    #MARKERS LISTING---------------------
                    analysis.markers <- 1:ncol(fcs@exprs)
                    names(analysis.markers) <- lapply(1:ncol(fcs@exprs), function(j)
                    {
                        d <- fcs@description[[paste0("$P",j,"S")]]
                        if(is.null(d) || !is.na(d) || d != "" || d != " ")
                        {
                            d <- global.values$fcs.files.ui.colnames[[f]][[j]]
                        }
                        names(d) <- NULL
                        
                        return(unlist(d))
                    })
                    updateSelectInput(session, "new_analysis_markers", label = "Select markers", choices=analysis.markers, selected = NULL)
                    
                }
            })
        }
    })
    
    observeEvent(input$new_analysis_add_param_button,#NEW ANALYSIS - PARAMETERS
    {
        shinyjs::disable("new_analysis_add_param_button")
        
        
        added.element.id <- length(global.values$analyses.parameters) + 1
        global.values$analyses.parameters[[paste0("param",added.element.id)]] <<- paste0("value",added.element.id)

        param.value <- global.values$analyses.parameters[[added.element.id]]
        param.name <- names(global.values$analyses.parameters)[added.element.id]
        
        insertUI("#new_analysis_parameters",
                 "beforeEnd",
                 fluidRow
                 (
                     id=paste0("param_",added.element.id),
                     box
                     (
                         width=4,
                         textInput(paste0("param_",added.element.id,"_name"), "Parameter name", value = param.name)
                     ),
                     box
                     (
                         width=5,
                         textInput(paste0("param_",added.element.id,"_value"), "Parameter value", value = param.value)
                     ),
                     box
                     (
                         width=3,
                         actionButton(paste0("param_",added.element.id,"_remove"), "Remove")
                     )
                 )
                 
        )
        
        observeEvent(input[[paste0("param_",added.element.id,"_remove")]],
        {
            global.values$analyses.parameters[[added.element.id]] <<- NA
            removeUI(paste0("#param_",added.element.id))
        })
        
        
        shinyjs::delay(500, shinyjs::enable("new_analysis_add_param_button"))
    })
    
    observe(#NEW ANALYSIS - UPDATE PARAMETERS LIST
    {
        if(length(global.values$analyses.parameters)>0)
        {
            lapply(1:length(global.values$analyses.parameters), function(p)
            {
                param <- global.values$analyses.parameters[[p]]
                if(is.defined(param) && is.defined(input[[paste0("param_",p,"_value")]]) && input[[paste0("param_",p,"_value")]] != "")
                {
                    global.values$analyses.parameters[[p]] <<- input[[paste0("param_",p,"_value")]]
                    names(global.values$analyses.parameters)[p] <<- input[[paste0("param_",p,"_name")]]
                }
            })
        }
    })
    
    observeEvent(input$new_analysis_save_button,
    {
        shinyjs::disable("new_analysis_save_button")
        progress.bar <- Progress$new()
        progress.bar$set(message="REGISTERING ANALYSIS", value = 0)
        on.exit(progress.bar$close())
        
        if((length(global.values$fcs.files) > 0)  && is.defined(global.values$fcs.files[[1]]))
        {
            if(is.defined(input$new_analysis_name) && input$new_analysis_name != "" && input$new_analysis_name != " ")
            {
                if(is.defined(input$new_analysis_column) && input$new_analysis_column != "" && input$new_analysis_column != " ")
                {
                    selected.markers <- "NULL"
                    if(is.defined(input$new_analysis_markers))
                    {
                        if(length(input$new_analysis_markers) > 0)
                        {
                            selected.markers <- ""
                            lapply(1:length(input$new_analysis_markers), function(m)
                            {
                                selected.markers <<- paste0(selected.markers, as.numeric(input$new_analysis_markers[[m]]), ".-.")
                            })
                        }
                    }
                    
                    selected.parameters <- "NULL"
                    if(length(global.values$analyses.parameters)>0)
                    {
                        selected.parameters <- ""
                        lapply(1:length(global.values$analyses.parameters), function(p)
                        {
                            param.value <- global.values$analyses.parameters[[p]]
                            param.name <- names(global.values$analyses.parameters)[p]
                            if(is.defined(param.value))
                            {
                                selected.parameters <<- paste0(selected.parameters, param.name, "-", param.value,".-.")
                            }
                        })
                    }
                    if(selected.parameters == "")
                    {
                        selected.parameters <- "NULL"
                    }
                    
                    new.entry <- paste0("CLMETH__",input$new_analysis_name,"__",input$new_analysis_column,"__",selected.markers,"__",selected.parameters)
                    new.entry.name <- paste0("CLMETH__",input$new_analysis_name,"__",input$new_analysis_column)
                    
                    global.values$fcs.files[[1]] <<- add.keyword.to.fcs(global.values$fcs.files[[1]], new.entry, new.entry.name)
                    progress.bar$inc(1, detail="Analysis Added")
                }
            }
        }
        
        progress.bar$set(message="Done", value = 1)
        shinyjs::enable("new_analysis_save_button")
    })
    
    
    output$files_dl <- downloadHandler(
        filename = function()
        {
            paste("output","fcs",sep=".")
        },
        content = function(file)
        {
            write.enriched.FCS(global.values$fcs.files[[1]],file)
        }
    )
    
    
}