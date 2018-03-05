tabPanel("Carte", 
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "input.update_module === 0",
                                                    h3("Veuillez sélectionner une étude et lancer l'analyse.")
                                   ),
                                   conditionalPanel(condition = "input.update_module > 0",
                                                    conditionalPanel(condition = "output.must_print_map", 
                                                                     includeMarkdown("src/aide/carte_before.md"),
                                                                     br(),
                                                                     uiOutput("plotMap_ui"),
                                                                     br(),
                                                                     includeMarkdown("src/aide/carte_after.md")
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
