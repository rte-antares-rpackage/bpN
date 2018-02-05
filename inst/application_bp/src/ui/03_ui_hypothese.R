tabPanel("Hypothèses",
         tabsetPanel(
           tabPanel("Production", 
                    br(),
                    fluidRow(
                      column(1, offset = 1,  h4("Zones : ")),
                      column(7,  selectInput("area_hyp_prod", NULL, choices = unique(hyp_prod$node), 
                                            selected = "fr", multiple = TRUE, width = "100%")),
                      column(2, div(actionButton("go_hyp_prod", "Valider"), align = "center"))
                    ),
                    amChartsOutput("hyp_prod", width = "100%", height = "650px")
           ),
           tabPanel("Consommation", verbatimTextOutput("summary")),
           tabPanel("Interconnexion", tableOutput("table"))
         )
)