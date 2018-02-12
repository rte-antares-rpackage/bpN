function(input, output, session) {

  #----------------
  # shared parameters
  #----------------
  
  modules <- reactiveValues(prodStack = NULL, exchangesStack = NULL, plotts = NULL, plotMap = NULL, 
                            id_prodStack = NULL, id_exchangesStack = NULL, id_plotts = NULL, id_plotMap = NULL,
                            init_prodStack = FALSE, init_exchangesStack = FALSE, init_plotts = FALSE, init_plotMap = FALSE)
  
  # all data loaded by user, with informations
  list_data_all <- reactiveValues(antaresDataList = .list_data_all$antaresDataList, 
                                  params = .list_data_all$params, 
                                  have_links = .list_data_all$have_links, 
                                  have_areas = .list_data_all$have_areas, 
                                  opts = .list_data_all$opts)
  
  # set of controls
  list_data_controls <- reactiveValues(have_links = FALSE, have_areas = FALSE, 
                                       n_links = -1, n_areas = -1, n_maps = -1)
  
  # control : have data
  output$have_data <- reactive({
    length(list_data_all$antaresDataList) > 0
  })
  outputOptions(output, "have_data", suspendWhenHidden = FALSE)
  
  #----------------
  # syntheses
  #----------------
  source("src/server/01_syntheses.R", local = T)
  
  #----------------
  # Hypotheses
  #----------------
  source("src/server/02_hypotheses.R", local = T)
  
  #----------------
  # Dataset selection
  #----------------
  source("src/server/03_data_selection.R", local = T)
  
  #----------------
  # shared inputs
  #----------------
  
  source("src/server/04_shared_input.R", local = T)
  
  #-----------------
  # modules
  #-----------------
  
  # launch when click on ""Launch Analysis" button
  # and get back which opts / data to keep
  ind_keep_list_data <- reactive({
    if(input$update_module > 0){
      isolate({
        if(length(input$sel_study > 0)){
          ind_all <- which(names(list_data_all$antaresDataList) %in% input$sel_study)
          list(ind_all = ind_all, ind_areas = ind_all, ind_links = ind_all)
        } else {
          showModal(modalDialog(
            "Pas d'étude(s) sélectionnée(s)",
            easyClose = TRUE,
            footer = NULL
          ))
          NULL
        }
      })
    } else {
      NULL
    }
  })
  
  #------------------
  # prodStack, plotTS & stackExchange
  #------------------
  
  source("src/server/05_modules.R", local = T)
  
  #------------
  # plotMap
  #------------
  
  source("src/server/06_module_map.R", local = T)
  
  #----------------
  # quit
  #----------------
  # buildExe <- FALSE
  # 
  # if(!buildExe)
  # {
  # # in case of classic use : 
  # observe({
  #   if(input$quit > 0){
  #     stopApp(returnValue = TRUE)
  #   }
  # })
  # }else{
  #   # in case of Rinno / packaging app for windows
  #   # (and so comment previous observe....!)
  #   #
  #   # in app mod
  #   observe({
  #     if(input$quit > 0){
  #       stopApp()
  #       q("no")
  #     }
  #   })
  # 
  #   session$onSessionEnded(function() {
  #     stopApp()
  #     q("no")
  #   })
  # }

}
