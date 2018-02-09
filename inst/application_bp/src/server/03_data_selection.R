#------------------
# gestion de la liste
#------------------
output$list_study <- renderUI({
  list_data <- list_data_all$antaresDataList
  if(length(list_data) > 0){
    isolate({
      selectInput("sel_study", label = NULL, choices = names(list_data), selected = names(list_data)[1], multiple = TRUE, width = "100%")
    })
  }
})
