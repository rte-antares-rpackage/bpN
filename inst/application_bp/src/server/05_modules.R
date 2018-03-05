observe({
  ind_keep_list_data <- ind_keep_list_data()
  isolate({
    if(input$update_module > 0){
      if(is.null(ind_keep_list_data)){
        showModal(modalDialog(
          easyClose = TRUE,
          footer = NULL,
          "Pas d'étude(s) sélectionnée(s)"
        ))
      } else {
        # plotts and prodStack
        ind_areas <- ind_keep_list_data$ind_areas
        if(length(ind_areas) > 0){
          # init / re-init module prodStack
          id_prodStack <- paste0("prodStack_", round(runif(1, 1, 100000000)))
          
          # update shared input table
          input_data$data[grepl("^prodStack", input_id), input_id := paste0(id_prodStack, "-shared_", input)]
          
          output[["prodStack_ui"]] <- renderUI({
            mwModuleUI(id = id_prodStack, height = "800px")
          })
          
          .compare <- .global_compare
          
          if(length(.compare) > 0 & input$use_compare){
            list_compare <- vector("list", length(.compare))
            names(list_compare) <- .compare
            # set main with study names
            if(length(ind_areas) != 1){
              list_compare$main <- names(list_data_all$antaresDataList[ind_areas])
            }
            .compare <- list_compare
          } else {
            if(length(ind_areas) > 1){
              .compare <- list(main = names(list_data_all$antaresDataList[ind_areas]))
            } else {
              .compare = NULL
            }
          }
          mod_prodStack <- prodStack(list_data_all$antaresDataList[ind_areas], xyCompare = "union",
                                     # h5requestFiltering = list_data_all$params[ind_areas],
                                     unit = "GWh", main = "Production", areas = "fr", mcYear = "1",
                                     interactive = TRUE, .updateBtn = TRUE, 
                                     .updateBtnInit = TRUE, compare = .compare, .runApp = FALSE, 
                                     language = "fr", hidden = c("stepPlot", "drawPoints", "main", "legend", "unit", "tables", "areas"))
          
          if("MWController" %in% class(modules$prodStack)){
            modules$prodStack$clear()
          }
          
          modules$prodStack <- mod_prodStack
          modules$id_prodStack <- id_prodStack
          modules$init_prodStack <- TRUE
          
          # init / re-init module plotts
          id_ts <- paste0("plotts_", round(runif(1, 1, 100000000)))
          
          # update shared input table
          input_data$data[grepl("^plotts", input_id), input_id := paste0(id_ts, "-shared_", input)]
          
          output[["plotts_ui"]] <- renderUI({
            mwModuleUI(id = id_ts, height = "800px")
          })
          
          .compare <- setdiff(.global_compare, "areas")
          
          if(length(.compare) > 0 & input$use_compare){
            list_compare <- vector("list", length(.compare))
            names(list_compare) <- .compare
            # set main with study names
            if(length(ind_areas) != 1){
              list_compare$main <- names(list_data_all$antaresDataList[ind_areas])
            }
            .compare <- list_compare
          } else {
            if(length(ind_areas) > 1){
              .compare <- list(main = names(list_data_all$antaresDataList[ind_areas]))
            } else {
              .compare = NULL
            }
          }
          mod_plotts <- plot(list_data_all$antaresDataList[ind_areas], xyCompare = "union",
                             h5requestFiltering = list_data_all$params[ind_areas],
                             variable = "consommation",
                             interactive = TRUE, .updateBtn = TRUE, language = "fr", elements = "fr",
                             hidden = c("main", "highlight", "stepPlot", "legend", "drawPoints", "confInt", 
                                        "aggregate", "secondAxis"), 
                             highlight = TRUE,
                             .updateBtnInit = TRUE, compare = .compare, .runApp = FALSE)
          
          if("MWController" %in% class(modules$plotts)){
            modules$plotts$clear()
          }
          
          modules$plotts <- mod_plotts
          modules$id_plotts <- id_ts
          modules$init_plotts <- TRUE
          
          list_data_controls$n_areas <- length(ind_areas)
          list_data_controls$have_areas <- TRUE
        } else {
          list_data_controls$have_areas <- FALSE
        }
        
        # exchange
        ind_links <- ind_keep_list_data$ind_links
        if(length(ind_links) > 0){
          # init / re-init module exchangesStack
          id_exchangesStack  <- paste0("exchangesStack_", round(runif(1, 1, 100000000)))
          
          # update shared input table
          input_data$data[grepl("^exchangesStack", input_id), input_id := paste0(id_exchangesStack, "-shared_", input)]
          
          output[["exchangesStack_ui"]] <- renderUI({
            mwModuleUI(id = id_exchangesStack, height = "800px")
          })
          
          .compare <- gsub("^areas$", "area", .global_compare)
          
          if(length(.compare) > 0 & input$use_compare){
            list_compare <- vector("list", length(.compare))
            names(list_compare) <- .compare
            # set main with study names
            if(length(ind_links) != 1){
              list_compare$main <- names(list_data_all$antaresDataList[ind_links])
            }
            .compare <- list_compare
          } else {
            if(length(ind_links) > 1){
              .compare <- list(main = names(list_data_all$antaresDataList[ind_links]))
            } else {
              .compare = NULL
            }
          }
          
          mod_exchangesStack <- exchangesStack(list_data_all$antaresDataList[ind_links], xyCompare = "union",
                                               h5requestFiltering = list_data_all$params[ind_links],
                                               interactive = TRUE, .updateBtn = TRUE, 
                                               mcYear = "1", main = "Echanges", unit = "GWh", area = "fr",
                                               stepPlot = TRUE, language = "fr", 
                                               hidden = c("stepPlot", "legend", "unit", "main", "drawPoints", "area"),
                                               .updateBtnInit = TRUE, compare = .compare, .runApp = FALSE)
          
          if("MWController" %in% class(modules$exchangesStack)){
            modules$exchangesStack$clear()
          }
          
          modules$exchangesStack <- mod_exchangesStack
          modules$id_exchangesStack <- id_exchangesStack
          modules$init_exchangesStack <- TRUE
          
          # save data and params
          list_data_controls$n_links <- length(ind_links)
          list_data_controls$have_links <- TRUE
        } else {
          list_data_controls$have_links <- FALSE
        }
        
        if(!list_data_controls$have_areas & !list_data_controls$have_links){
          showModal(modalDialog(
            easyClose = TRUE,
            footer = NULL,
            "Pas d'étude(s) sélectionnée(s)"
          ))
        }
      }
    }
    
    input_data$cpt <- isolate(input_data$cpt) +1
  })
})

# call module when click on tab if needed
observe({
  if(input[['res_tab_id']] == "Production" & modules$init_prodStack){
    isolate({
      if("MWController" %in% class(modules$prodStack) & modules$init_prodStack){
        modules$prodStack <- mwModule(id = modules$id_prodStack,  modules$prodStack)
        modules$init_prodStack <- FALSE
      }
    })
  }
})

observe({
  if(input[['res_tab_id']] == "Chroniques"){
    isolate({
      if("MWController" %in% class(modules$plotts) & modules$init_plotts){
        modules$plotts <- mwModule(id = modules$id_plotts,  modules$plotts)
        modules$init_plotts <- FALSE
      }
    })
  }
})

observe({
  if(input[['res_tab_id']] == "Echanges"){
    isolate({
      if("MWController" %in% class(modules$exchangesStack) & modules$init_exchangesStack){
        modules$exchangesStack <- mwModule(id = modules$id_exchangesStack,  modules$exchangesStack)
        modules$init_exchangesStack <- FALSE
      }
    })
  }
})




# control : have link in data
output$have_data_links <- reactive({
  list_data_controls$have_links
})
outputOptions(output, "have_data_links", suspendWhenHidden = FALSE)

# control : have areas in data
output$have_data_areas <- reactive({
  list_data_controls$have_areas
})
outputOptions(output, "have_data_areas", suspendWhenHidden = FALSE)

# change page
observe({
  if(input$update_module > 0){
    if(list_data_controls$have_areas & list_data_controls$n_areas >= 1){
      updateNavbarPage(session, inputId = "res_tab_id", selected = "Production")
    } else if(list_data_controls$have_links & list_data_controls$n_links >= 1){
      updateNavbarPage(session, inputId = "res_tab_id", selected = "Echanges")
    }
  }
})