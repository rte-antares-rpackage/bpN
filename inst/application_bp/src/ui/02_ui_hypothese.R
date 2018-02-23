tabPanel("Principaux résultats et hypothèses",
         fluidRow(
           column(2, div(h4("Scénario sélectionné :"), align = "left")),
           column(2,  selectInput("hyp_scenario", NULL, c("Ampère", "Hertz", "Volt", "Watt")))
         ),
         tabsetPanel(
           tabPanel("Généralités", 
                    br(),
                    uiOutput("md_gen")
           ),
           tabPanel("Consommation",
                    br(),
                    includeMarkdown("src/aide/hypotheses_conso_before.md"),
                    br(),
                    fluidRow(
                      column(1,  div(h4("Type : "), align = "center")), 
                      column(2,  selectInput("type_hyp_conso", NULL, choices = c("Secteur", "Usage"), 
                                             selected = "Secteur", multiple = FALSE, width = "100%")),
                      column(1,  div(h4("Affichage : "), align = "center")), 
                      column(2, selectInput("stack_hyp_conso", NULL, choices = c("Valeurs" = "regular", "Pourcentages" = "100%"), 
                                            selected = "regular", multiple = FALSE, width = "100%"))
                    ),
                    uiOutput("hyp_conso_graph"),
                    br(),
                    includeMarkdown("src/aide/hypotheses_conso_after.md")
           ),
           tabPanel("Parc de production", 
                    br(),
                    includeMarkdown("src/aide/hypotheses_parc_production.md"),
                    br(),
                    fluidRow(
                      # column(1,  div(h4("Pays : "), align = "center")),
                      # column(2,  selectInput("area_hyp_prod", NULL, choices = unique(hyp_prod$node), 
                      #                        selected = "fr", multiple = TRUE, width = "100%")),
                      # column(2, div(actionButton("go_hyp_prod", "Valider"), align = "center")),
                      column(1,  div(h4("Affichage : "), align = "center")), 
                      column(2, selectInput("stack_hyp_prod", NULL, choices = c("Valeurs" = "regular", "Pourcentages" = "100%"), 
                                            selected = "regular", multiple = FALSE, width = "100%"))
                    ),
                    
                    fluidRow(
                      column(6, offset = 3, amChartsOutput("hyp_prod", width = "100%", height = "500px"))
                    )
                    
           ),
           tabPanel("Interconnexions", 
                    br(),
                    includeMarkdown("src/aide/hypotheses_interco_before.md"),
                    br(),
                    fluidRow(
                      # column(1,  div(h4("Affichage : "), align = "center"), 
                      #        selectInput("stack_hyp_inter", NULL, choices = c("Valeurs" = "regular", "Pourcentages" = "100%"), 
                      #                    selected = "regular", multiple = FALSE, width = "100%")
                      # ), 
                      
                      column(5,  offset = 1, amChartsOutput("hyp_inter_import", width = "100%", height = "450px")),
                      column(5, amChartsOutput("hyp_inter_export", width = "100%", height = "450px"))
                    )
                    # ,
                    # br()
                    # includeMarkdown("src/aide/hypotheses_interco_after.md")
           ),
           tabPanel("Bilans", 
                    br(),
                    includeMarkdown("src/aide/hypotheses_bilans.md"),
                    br(),
                    fluidRow(
                      
                      column(1, offset = 1, br(), br(), img(src = "img/legend_bilan.png", height = "350px")),
                      column(3,  
                             div(class = "bilan_charts", amChartsOutput("bilan_1_1"), amChartsOutput("bilan_1_2")),
                             uiOutput("info_bilan_1")
                      ),
                      column(3,  
                             div(class = "bilan_charts", amChartsOutput("bilan_2_1"), amChartsOutput("bilan_2_2")),
                             uiOutput("info_bilan_2")
                      ),
                      column(3,  
                             div(class = "bilan_charts", amChartsOutput("bilan_3_1"), amChartsOutput("bilan_3_2")),
                             uiOutput("info_bilan_3")
                      )
                      
                    )
           ) ,
           tabPanel("CO2", 
                    br(),
                    includeMarkdown("src/aide/hypotheses_co2_before.md"),
                    br(),
                    fluidRow(
                      column(width = 6, offset = 3, amChartsOutput("hyp_co2", width = "100%", height = "500px"))
                    )
                    # ,
                    # br(),
                    # includeMarkdown("src/aide/hypotheses_co2_after.md")
                    
           )
         )
)