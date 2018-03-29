# Define UI for bpNumerique2018 app
navbarPage(title = HTML('<p style="margin-top: 0.05cm;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bilan prévisionnel 2017</p>'), id = "nav-id", theme = "css/custom.css", collapsible = TRUE, position = "fixed-top",
           header = div(
             br(), br(), br(), br(), br(), a(href = "http://www.rte-france.com/fr/article/bilan-previsionnel",
                                       target = "_blank", img(src = "img/Logo_RTE.png", class = "ribbon")),
             singleton(tags$script(src = 'events.js')),
             singleton(tags$script(src = 'is.min.js')),
             tags$script(type="text/javascript", 'if(is.ie()){ alert("Ce site n\'est pas optimisé pour Internet Explorer");};'),
             div(id = "import_busy", tags$img(src= "spinner.gif", height = 100,
                                              style = "position: fixed;top: 50%;z-index:10;left: 48%;")),
             
             # div(class = "rte_footer", HTML("Plus d'informations sur la page <a href='http://www.rte-france.com/fr/article/bilan-previsionnel' target='_blank'>www.rte-france.com/fr/article/bilan-previsionnel</a>   
             #                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Les données présentées sont téléchargeables sur la plateforme <a href='https://opendata.reseaux-energies.fr/pages/accueil/' target='_blank' style = 'color:black'>Open Data Réseaux Energies</a>"))
             
             div(class = "rte_footer", HTML("Plus d'informations sur la page <a href='http://www.rte-france.com/fr/article/bilan-previsionnel' target='_blank'>www.rte-france.com/fr/article/bilan-previsionnel</a>"))
             
             # ), windowTitle = div(img(src="img/RTE_logo.svg.png"), "BP 2017 RTE - Accueil"),
           ),windowTitle = "BP 2017 RTE - Accueil",
           # source("src/ui/01_ui_syntheses.R", local = T)$value,
           
           source("src/ui/02_ui_hypothese.R", local = T, encoding="UTF-8")$value,
           
           tabPanel("Analyse détaillée",
                    
                    source("src/ui/03_ui_data_selection.R", local = T, encoding="UTF-8")$value,
                    
                    conditionalPanel(condition = "input.update_module > 0 && output.have_data_areas === true",
                                     tabsetPanel(id = "res_tab_id",
                                                 
                                                 source("src/ui/04_ui_prodstack.R", local = T, encoding="UTF-8")$value,
                                                 
                                                 source("src/ui/05_ui_exchange.R", local = T, encoding="UTF-8")$value,
                                                 
                                                 source("src/ui/06_ui_tsplot.R", local = T, encoding="UTF-8")$value,
                                                 
                                                 source("src/ui/07_ui_map.R", local = T, encoding="UTF-8")$value
                                     )
                    )
                    
                    
           ),
           source("src/ui/08_ui_help.R", local = T, encoding="UTF-8")$value,
           footer = div(br(), br())
)



