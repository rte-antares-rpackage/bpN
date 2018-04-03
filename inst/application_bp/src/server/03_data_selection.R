#------------------
# gestion de la liste
#------------------
output$list_study <- renderUI({
  list_data <- list_data_all$antaresDataList
  if(length(list_data) > 0){
    choices = names(list_data)
    names(choices) <- gsub(".h5$", "", choices)
    choices <- choices[c(which(!grepl("^Ohm", choices)), which(grepl("^Ohm", choices)))]
    isolate({
      selectizeInput("sel_study", label = NULL, choices = choices, selected = NULL, multiple = TRUE, 
                     width = "100%", options = list(maxItems = 4))
    })
  }
})
