ml <- reactiveVal(ml_data)

# control : have a not null layout, and so print map module ?
print_map <- reactiveValues(value = FALSE)

observe({
  if(!is.null(ml())){
    print_map$value <- TRUE
  } else {
    print_map$value <- FALSE
  }
})


output$must_print_map <- reactive({
  print_map$value
})

outputOptions(output, "must_print_map", suspendWhenHidden = FALSE)

observe({
  ml <- ml()
  ind_keep_list_data <- ind_keep_list_data()
  isolate({
    if(input$update_module > 0){
      if(!is.null(ind_keep_list_data)){
        ind_map <- unique(sort(c(ind_keep_list_data$ind_areas, ind_keep_list_data$ind_links)))
        if(length(ind_map) > 0){
          if(!is.null(ml)){
            # init / re-init module plotMap
            id_plotMap   <- paste0("plotMap_", round(runif(1, 1, 100000000)))
            
            # update shared input table
            input_data$data[grepl("^plotMap", input_id), input_id := paste0(id_plotMap, "-shared_", input)]
            
            output[["plotMap_ui"]] <- renderUI({
              mwModuleUI(id = id_plotMap, height = "800px")
            })
            
            .compare <- setdiff(input$sel_compare, "areas")
            
            if(length(.compare) > 0 & input$use_compare){
              list_compare <- vector("list", length(.compare))
              names(list_compare) <- .compare
              # set main with study names
              if(length(ind_map) != 1){
                list_compare$main <- names(list_data_all$antaresDataList[ind_map])
              }
              .compare <- list_compare
            } else {
              .compare = NULL
            }
            
            mod_plotMap <- plotMap(list_data_all$antaresDataList[ind_map], ml, 
                                   interactive = TRUE, .updateBtn = TRUE, 
                                   .updateBtnInit = TRUE, compare = .compare,
                                   h5requestFiltering = list_data_all$params[ind_map],
                                   language = "fr", 
                                   hidden = c("showLabels", "popupLinkVars", "uniqueScale", "showLabels"),
                                   # colAreaVar ="LOAD", areaChartType = "pie", sizeMiniPlot = TRUE,
                                   # sizeAreaVars = c("NUCLEAR", "LIGNITE", "COAL", "GAS", "OIL", "MIX. FUEL", "MISC. DTG", "H. STOR", "WIND", "SOLAR", "H. ROR", "MISC. NDG"),
                                   # colLinkVar = "CONG. FEE (ABS.)", sizeLinkVar = "FLOW LIN.",
                                   xyCompare = "union", .runApp = FALSE)
            
            if("MWController" %in% class(modules$plotMap)){
              modules$plotMap$clear()
            }
            
            modules$plotMap <- mwModule(id = id_plotMap,  mod_plotMap)
            # save data and params
            list_data_controls$n_maps <- length(ind_map)
          }
        }
      }
    }
  })
})