fluidRow(
  column(12,
         conditionalPanel(condition = "output.have_data === true",
                          div(h3("Périmètre de l'analyse"), align = "center"),
                          hr(),
                          fluidRow(
                            column(12, 
                                   h4("Sélection des études :"),
                                   uiOutput("info_list")
                                   )

                          ),
                          
                          fluidRow(
                          column(6, 
                                 checkboxInput("use_compare", "Ajout d'axes de comparaison", FALSE),
                                 conditionalPanel(condition = "input.use_compare === true",
                                                  selectInput("sel_compare", "", choices = .global_compare, selected = NULL, multiple = TRUE)
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