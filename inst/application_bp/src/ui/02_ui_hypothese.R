tabPanel("Hypothèses",
         selectInput("hyp_scenario", "Scénario : ", c("Ampère", "Hertz", "Volt", "Watt")),
         tabsetPanel(
           tabPanel("Généralités", 
                    br(),
                    uiOutput("md_gen")
           ),
           tabPanel("Parc de production", 
                    br(),
                    fluidRow(
                      column(1,  div(h4("Pays : "), align = "center")),
                      column(2,  selectInput("area_hyp_prod", NULL, choices = unique(hyp_prod$node), 
                                             selected = "fr", multiple = TRUE, width = "100%")),
                      column(2, div(actionButton("go_hyp_prod", "Valider"), align = "center"))
                    ),
                    amChartsOutput("hyp_prod", width = "100%", height = "650px")
           ),
           tabPanel("Consommation", 
                    br(),
                    fluidRow(
                      column(1,  div(h4("Type : "), align = "center")), 
                      column(2,  selectInput("type_hyp_conso", NULL, choices = c("Secteur", "Usage"), 
                                             selected = "Secteur", multiple = FALSE, width = "100%"))
                    ),
                    uiOutput("hyp_conso_graph")
           ),
           tabPanel("Interconnexions", 
                    br(),
                    fluidRow(
                      column(6, amChartsOutput("hyp_inter_import", width = "100%", height = "650px")),
                      column(6, amChartsOutput("hyp_inter_export", width = "100%", height = "650px"))
                    )
           ) ,
           tabPanel("CO2", 
                    br(),
                    includeMarkdown("src/aide/hypotheses_co2_before.md"),
                    br(),
                    fluidRow(
                      column(width = 6, offset = 3, amChartsOutput("hyp_co2", width = "100%", height = "500px"))
                    ),
                    br(),
                    includeMarkdown("src/aide/hypotheses_co2_after.md")
                    
           )
         )
)