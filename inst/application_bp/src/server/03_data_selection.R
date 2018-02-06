#------------------
# gestion de la liste
#------------------
output$info_list <- renderUI({
  list_data <- list_data_all$antaresDataList
  if(length(list_data) > 0){
    isolate({
      # affichage du nom de l'etude
      study <- lapply(1:length(list_data), function(i) {
        study_name <- paste0("list_study_", i)
        div(
          h4(textOutput(study_name)), style = 'height:24px', align = "left")
      })
      # checkbox de selection
      check_list <- lapply(1:length(list_data), function(i) {
        check_name <- paste0("list_study_check", i)
        div(
          checkboxInput(check_name, "Inclure l'étude dans l'analyse", value = TRUE), align = "left")
      })

      # format et retour
      ind_impair <- seq(1, length(list_data), by = 2)
      ind_pair <- seq(2, length(list_data), by = 2)
      fluidRow(
        column(3, do.call(tagList, study[ind_impair])),
        column(2, do.call(tagList, check_list[ind_impair])),
        column(3, do.call(tagList, study[ind_pair])),
        column(2, do.call(tagList, check_list[ind_pair]))
      )
    })
  }else {
    # element vide si pas de donnees
    fluidRow()
  }
})

# creation des outputs
# - titre de l'etude
# - print des parametres
observe({
  # lancement lors de la recuperation des donnees formatees
  list_data_tmp <- list_data_all$antaresDataList
  if(length(list_data_tmp) > 0){
    isolate({
      ctrl <- lapply(1:length(list_data_tmp), function(i) {
        study_name <- paste0("list_study_", i)
        study_params <- paste0("list_study_params", i)
        output[[study_name]] <- renderText({
          paste0("Etude : ", names(list_data_tmp)[i])
        })
      })
    })
  }
})

