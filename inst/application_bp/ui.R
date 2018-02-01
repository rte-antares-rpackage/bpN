# Define UI for bpNumerique2018 app
navbarPage(title = "Bilan Prévisionnel 2017", id = "nav-id", theme = "css/custom.css", collapsible = TRUE, position = "fixed-top",
           header = div(
                    br(), br(), br(), a(href = "http://www.rte-france.com/fr/article/bilan-previsionnel",
                                        target = "_blank", img(src = "img/RTE_logo.svg.png", class = "ribbon")),
                    singleton(tags$script(src = 'events.js')),
                    div(id = "import_busy", tags$img(src= "spinner.gif", height = 100,
                                                     style = "position: fixed;top: 50%;z-index:10;left: 48%;"))
             
           ), windowTitle = "BP 2017",
           tabPanel("Données",
                    source("src/ui/04_ui_analysis.R", local = T)$value
           ),
           
           tabPanel("Synthèse",
                    fluidRow(
                      "TO DO"
                    )
           ),
           
           tabPanel("Hypothèses",
                    fluidRow(
                      "TO DO"
                    )
           ),
           
           source("src/ui/05_ui_prodstack.R", local = T)$value,
           
           source("src/ui/06_ui_exchange.R", local = T)$value,
           
           source("src/ui/07_ui_tsplot.R", local = T)$value,
           
           source("src/ui/08_ui_map.R", local = T)$value,
           
           source("src/ui/10_ui_help.R", local = T)$value,
           
           footer = div(hr(), actionButton("quit", "Quit application", icon = icon("sign-out")), align = "center")
)



