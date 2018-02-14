tabPanel("Hypothèses",
         selectInput("hyp_scenario", "Scénario : ", c("Ampère", "Hertz", "Volt", "Watt")),
         tabsetPanel(
           tabPanel("Généralités", 
                    br(),
                    uiOutput("md_gen")
           ),
           tabPanel("Production", 
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
                      column(2,  selectInput("type_hyp_conso", NULL, choices = c("Secteur", "Usage", "Branche"), 
                                             selected = "Secteur", multiple = FALSE, width = "100%"))
                    ),
                    uiOutput("hyp_conso_graph")
           ),
           tabPanel("Interconnexions", 
                    fluidRow(
                      column(6, amChartsOutput("hyp_inter_import", width = "100%", height = "650px")),
                      column(6, amChartsOutput("hyp_inter_export", width = "100%", height = "650px"))
                    )
           )         
         )
)