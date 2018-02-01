tabPanel("Echanges",
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "output.have_data_links",
                                                    uiOutput("exchangesStack_ui")
                                   ),
                                   conditionalPanel(condition = "output.have_data_links === false",
                                                    h3("Pas de liens présents dans les données.")
                                   )
                  ),
                  conditionalPanel(condition = "output.have_data === false",
                                   h3("Pas de données importées depuis l'onglet 'Données'.")
                  )
           )
         )
)