tabPanel("Synthèse",
         fluidRow(
           column(12,
                  navlistPanel(id = "synth_tab", widths = c(2, 10),
                               tabPanel("Les scénarios", 
                                        "TO DO"
                               ),
                               tabPanel("Ampère",  
                                        tabsetPanel(id = "synth_tab_amp",
                                                    tabPanel("Principe"),
                                                    tabPanel("Hypothèses principales"),
                                                    tabPanel("Résultats")
                                        )
                               ),
                               
                               tabPanel("Hertz",  
                                        tabsetPanel(id = "synth_tab_hertz",
                                                    tabPanel("Principe"),
                                                    tabPanel("Hypothèses principales"),
                                                    tabPanel("Résultats")
                                        )
                               ),
                               tabPanel("Volt",  
                                        tabsetPanel(id = "synth_tab_volt",
                                                    tabPanel("Principe"),
                                                    tabPanel("Hypothèses principales"),
                                                    tabPanel("Résultats")
                                        )
                               ),
                               tabPanel("Watt",  
                                        tabsetPanel(id = "synth_tab_watt",
                                                    tabPanel("Principe"),
                                                    tabPanel("Hypothèses principales"),
                                                    tabPanel("Résultats")
                                        )
                               )
                  )
           )
         )
         
)