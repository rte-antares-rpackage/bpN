tabPanel("Echanges",
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "output.have_data_links",
                                                    includeMarkdown("src/aide/echanges_before.md"),
                                                    br(),
                                                    uiOutput("exchangesStack_ui"),
                                                    br(),
                                                    includeMarkdown("src/aide/echanges_after.md")
                                   ),
                                   conditionalPanel(condition = "output.have_data_links === false",
                                                    conditionalPanel(condition = "input.update_module === 0",
                                                                     h3("Veuillez sélectionner une étude et lancer l'analyse.")
                                                    ),
                                                    conditionalPanel(condition = "input.update_module > 0",
                                                                     h3("Pas de liens présents dans les données.")
                                                    )
                                                    
                                   )
                  ),
                  conditionalPanel(condition = "output.have_data === false",
                                   conditionalPanel(condition = "input.update_module === 0",
                                                    h3("Veuillez sélectionner une étude et lancer l'analyse.")
                                   ),
                                   conditionalPanel(condition = "input.update_module > 0",
                                                    h3("Pas de données importées.")
                                   )
                  )
           )
         )
)