fluidRow(
  column(12,
         conditionalPanel(condition = "output.have_data === true",
                          div(h3("Sélection des études :"), align = "center"),
                          fluidRow(
                            column(10, 
                                   uiOutput("info_list")
                            ), 
                            column(2, 
                                   div(
                                     checkboxInput("use_compare", "Ajout d'axes de comparaison", FALSE),
                                     conditionalPanel(condition = "input.use_compare === true",
                                                      selectInput("sel_compare", NULL, choices = .global_compare, selected = NULL, multiple = TRUE)),
                                     align = "center"
                                   )
                            )
                            
                          ), 
                          br(),
                          div(actionButton("update_module", "Lancement de l'analyse", icon = icon("upload")), align = "center")
         ),
         conditionalPanel(condition = "output.have_data === false",
                          h3("Pas de données disponibles dans l'application", style = "color : red")
         )
  )
)