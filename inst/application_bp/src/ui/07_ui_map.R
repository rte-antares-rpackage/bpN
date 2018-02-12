tabPanel("Carte", 
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "input.update_module === 0",
                                                    h3("Veuillez sélectionner une étude et lancer l'analyse.")
                                   ),
                                   conditionalPanel(condition = "input.update_module > 0",
                                                    conditionalPanel(condition = "output.must_print_map", 
                                                                     uiOutput("plotMap_ui")
                                                    ), 
                                                    conditionalPanel(condition = "output.must_print_map === false", 
                                                                     h3("Erreur lors de l'importation du fond de carte...")
                                                    )
                                   )
                                   
                  ),
                  conditionalPanel(condition = "output.have_data === false",
                                   h3("Pas de données importées.")
                  )
           )
         )
)
