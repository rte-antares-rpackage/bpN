tabPanel("Production",
         fluidRow(
           column(12,
                  conditionalPanel(condition = "output.have_data",
                                   conditionalPanel(condition = "output.have_data_areas",
                                                    uiOutput("prodStack_ui")
                                   ),
                                   conditionalPanel(condition = "output.have_data_areas === false",
                                                    h3("Pas de noeuds présents dans les données.")
                                   )
                  ),
                  conditionalPanel(condition = "output.have_data === false",
                                   h3("Pas de données importées depuis l'onglet 'Données'.")
                  )
           )
         )
)