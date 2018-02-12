fluidRow(
  column(12,
         conditionalPanel(condition = "output.have_data === true",
                          fluidRow(
                            column(1, div(h4("Etudes : "), align = "center")),
                            column(5, uiOutput("list_study")),
                            column(2, div(checkboxInput("use_compare", "Ajout d'axes de comparaison", FALSE), align = "center")),
                            column(2, div(conditionalPanel(condition = "input.use_compare === true",
                                                           selectInput("sel_compare", NULL, choices = .global_compare, selected = NULL, multiple = TRUE)), align = "center")),
                            column(2, div(actionButton("update_module", "Lancement de l'analyse", icon = icon("upload")), align = "center"))
                          )
         ),
         conditionalPanel(condition = "output.have_data === false",
                          h3("Pas de données disponibles dans l'application", style = "color : red")
         )
  ),
  conditionalPanel(condition = "input.update_module === 0",
                   div(h3("Veuillez sélectionner une étude et lancer l'analyse."), align =" center")
  ),
  conditionalPanel(condition = "input.update_module > 0 && output.have_data_areas === false",
                   div(h3("Pas de données importées."), align =" center")
  )
)