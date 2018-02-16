#------------
# generalites
#------------

output$md_gen <- renderUI({
  switch(input$hyp_scenario, 
         "Ampère" = fluidRow(
           column(12, includeMarkdown("src/aide/ampere_onglet_gen.md"))
         ), 
         "Hertz" = fluidRow(
           column(12, includeMarkdown("src/aide/hertz_onglet_gen.md"))
         ), 
         "Volt" = fluidRow(
           column(12, includeMarkdown("src/aide/volt_onglet_gen.md"))
         ), 
         "Watt" = fluidRow(
           column(12, includeMarkdown("src/aide/watt_onglet_gen.md"))
         ))
})




#------------
# production
#------------
output$hyp_prod <- renderAmCharts({
  
  input$hyp_scenario
  input$go_hyp_prod
  isolate({
    res <- getProductionHypothesis(data = hyp_prod, nodes = input$area_hyp_prod, sce_prod = sce_prod, scenario = input$hyp_scenario)
    
    gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                     stack_type = "regular", legend = TRUE,
                     groups_color = unname(prod_col[colnames(res)[-1]]), 
                     # main = paste0("Évolution du parc installé (scénario ", input$hyp_scenario, ")"),
                     main = "Évolution du parc installé",
                     zoom = TRUE, show_values = FALSE, ylab = "MW",
                     labelRotation = 45, legendPosition = "bottom", height = "800")  %>%
      setExport(enabled = TRUE, menu = ramcharts_menu_obj)
    
    gr@otherProperties$thousandsSeparator <- " "
    gr
  })
})

#------------
# consommation
#------------
output$hyp_conso <- renderAmCharts({
  
  type <- input$type_hyp_conso
  res <- getConsoHypothesis(data = hyp_conso, type = type, sce_prod = sce_prod, scenario = input$hyp_scenario)
  
  if(type == "Secteur"){
    groups_color = unname(secteur_col[colnames(res)[-1]])
  } else {
    groups_color = unname(cl_hyp_prod[1:(ncol(res) - 1)])
  }
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = groups_color, 
                   # main = paste0("Hypothèses de consommation (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution de la consommation",
                   zoom = ifelse(type == "Branche", FALSE, TRUE), 
                   show_values = FALSE, ylab = "TWh",
                   # horiz = ifelse(type == "Branche", TRUE, FALSE),
                   labelRotation = 45, legendPosition = "bottom", height = "800")  %>%
    setExport(enabled = TRUE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  
  if(type == "Branche"){
    gr <- setChartCursor(.Object = gr, valueZoomable = TRUE, 
                         valueLineEnabled = TRUE, zoomable = TRUE, 
                         valueLineBalloonEnabled = TRUE, valueBalloonsEnabled = FALSE)
  }
  gr
})

output$hyp_conso_graph <- renderUI({
  if(input$type_hyp_conso == "Branche"){
    amChartsOutput("hyp_conso", width = "100%", height = "1050px")
  } else {
    amChartsOutput("hyp_conso", width = "100%", height = "650px")
  }
})


#------------
# interco
#------------

res_inter <- reactive({
  getIntercoHypothesis(data = hyp_inter, sce_prod = sce_prod, scenario = input$hyp_scenario)
})

output$hyp_inter_import <- renderAmCharts({
  
  res <- res_inter()$import
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_interco[1:(ncol(res) - 1)]), 
                   # main = paste0("Évolution des capacités d'import (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution des capacités d'import",
                   zoom = TRUE, show_values = FALSE, ylab = "MW",
                   labelRotation = 45, height = "800")  %>%
    setExport(enabled = TRUE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  gr
})

output$hyp_inter_export <- renderAmCharts({
  
  res <- res_inter()$export
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_interco[1:(ncol(res) - 1)]), 
                   # main = paste0("Évolution des capacités d'export (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution des capacités d'export",
                   zoom = TRUE, show_values = FALSE, ylab = "MW",
                   labelRotation = 45, height = "800")  %>%
    setExport(enabled = TRUE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  gr
})


#------------
# co2
#------------

output$hyp_co2<- renderAmCharts({
  
  tmp <- data.frame(date = colnames(hyp_co2)[-1], historique = t(data.frame(hyp_co2[scenario %in% input$hyp_scenario, ][, scenario := NULL]))[, 1])
  tmp$scenario <- tmp$historique
  tmp$scenario[1:5] <- NA
  tmp$historique[6:8] <- NA
  
  amBarplot(x = "date", y = c("scenario", "historique"), data = tmp,
            stack_type = "regular", legend = TRUE,
            # main = paste0("Évolution des émissions de CO2 en France (scénario ", input$hyp_scenario, ")"),
            main = "Évolution des émissions de CO2 en France",
            zoom = TRUE, show_values = FALSE,
            ylab = "Millions de tonnes (Mt)", horiz = FALSE,
            labelRotation = 45, theme = "pattern", creditsPosition = "top-right")  %>%
    setExport(enabled = TRUE, menu = ramcharts_menu_obj)
  
})


#-------------
# bilan
#-------------

data_bilan <- reactive({
  getBilan(hyp_bilan, hyp_co2, table_couleur_bilan)
})

output$bilan_1_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  amPie(data = data_bilan$pie_conso_2025, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 60, radius = 100,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
})

output$bilan_1_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2025, show_values = TRUE, 
                         innerRadius = 100, radius = 140, 
                         legend = FALSE, creditsPosition = "bottom-left",
                         labelText =  "[[value]]",
                         labelRadius = -20, bringToFront = TRUE,
                         labelColor = "white",
                         allLabels = list(list(
                           text = "Bilan énergétique en 2025",
                           size = 18,
                           color = "#404040",
                           x = 0,
                           align = "center",
                           y =20), 
                           list(
                             text = paste(data_bilan$twh_2025, "TWh"),
                             size = 18,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_1 <- renderUI({
  data_bilan <- data_bilan()
  fluidRow(
    column(4, div(paste("CO2", data_bilan$co2_2025, "Mt"), style = "position: absolute; z-index : 100; width:90%;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("leaf"), paste(data_bilan$enr_2025, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("industry"), paste(data_bilan$nuc_2025, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
  )
})

output$bilan_2_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  amPie(data = data_bilan$pie_conso_2030, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 60, radius = 100,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
})

output$bilan_2_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2030, show_values = TRUE, 
                         innerRadius = 100, radius = 140, 
                         legend = FALSE, creditsPosition = "bottom-left",
                         labelText =  "[[value]]",
                         labelRadius = -20, bringToFront = TRUE,
                         labelColor = "white",
                         allLabels = list(list(
                           text = "Bilan énergétique en 2030",
                           size = 18,
                           color = "#404040",
                           x = 0,
                           align = "center",
                           y =20), 
                           list(
                             text = paste(data_bilan$twh_2030, "TWh"),
                             size = 18,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_2 <- renderUI({
  data_bilan <- data_bilan()
  fluidRow(
    column(4, div(paste("CO2", data_bilan$co2_2030, "Mt"), style = "position: absolute; z-index : 100; width:90%;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("leaf"), paste(data_bilan$enr_2030, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("industry"), paste(data_bilan$nuc_2030, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
  )
})

output$bilan_3_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  amPie(data = data_bilan$pie_conso_2035, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 60, radius = 100,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
})

output$bilan_3_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2035, show_values = TRUE, 
                         innerRadius = 100, radius = 140, 
                         legend = FALSE, creditsPosition = "bottom-left",
                         labelText =  "[[value]]",
                         labelRadius = -20, bringToFront = TRUE,
                         labelColor = "white",
                         allLabels = list(list(
                           text = "Bilan énergétique en 2035",
                           size = 18,
                           color = "#404040",
                           x = 0,
                           align = "center",
                           y =20), 
                           list(
                             text = paste(data_bilan$twh_2035, "TWh"),
                             size = 18,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_3 <- renderUI({
  data_bilan <- data_bilan()
  fluidRow(
    column(4, div(paste("CO2", data_bilan$co2_2035, "Mt"), style = "position: absolute; z-index : 100; width:90%;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("leaf"), paste(data_bilan$enr_2035, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
    column(4, div(icon("industry"), paste(data_bilan$nuc_2035, "%"), style = "position: absolute; z-index : 100; width:90%; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
  )
})