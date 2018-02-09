tabPanel("Production",
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "output.have_data_areas",
                                                    uiOutput("prodStack_ui")
                                   ),
                                   conditionalPanel(condition = "output.have_data_areas === false",
                                                    conditionalPanel(condition = "input.update_module === 0",
                                                                     h3("Veuillez sélectionner une étude et lancer l'analyse.")
                                                    ),
                                                    conditionalPanel(condition = "input.update_module > 0",
                                                                     h3("Pas de noeuds présents dans les données.")
                                                    )
                                   )
                  ),
                  conditionalPanel(condition = "output.have_data === false",
                                   conditionalPanel(condition = "input.update_module === 0",
                                                    h3("Veuillez sélectionner une étude et lancer l'analyse")
                                   ),
                                   conditionalPanel(condition = "input.update_module > 0",
                                                    h3("Pas de données importées.")
                                   )
                                  
                  )
           )
         )
)