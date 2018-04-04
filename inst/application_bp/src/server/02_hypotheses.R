#------------
# generalites
#------------

output$md_gen <- renderUI({
  switch(input$hyp_scenario, 
         "Ampère" = fluidRow(
           column(5, img(src= "img/img_fiche_ampere.png", width = "100%")),
           column(7, includeMarkdown("src/aide/hypotheses_generalites_ampere_2.md"))
         ), 
         "Hertz" = fluidRow(
           column(5, img(src= "img/img_fiche_hertz.png", width = "100%")),
           column(7, includeMarkdown("src/aide/hypotheses_generalites_hertz_2.md"))
         ), 
         "Volt" = fluidRow(
           column(5, img(src= "img/img_fiche_volt.png", width = "100%")),
           column(7, includeMarkdown("src/aide/hypotheses_generalites_volt_2.md"))
         ), 
         "Watt" = fluidRow(
           column(5, img(src= "img/img_fiche_watt.png", width = "100%")),
           column(7, includeMarkdown("src/aide/hypotheses_generalites_watt_2.md"))
         ),
         "Ohm" = fluidRow(
           column(5, img(src= "img/img_fiche_ohm.png", width = "100%")),
           column(7, includeMarkdown("src/aide/hypotheses_generalites_ohm.md"))
         ))
})


#------------
# variantes
#------------

output$img_var <- renderUI({
  switch(input$hyp_scenario, 
         "Ampère" = fluidRow(
           column(12, div(img(src= "img/img_bingo_ampere.png"), align = "center"))
         ), 
         "Hertz" = fluidRow(
           column(12, div(img(src= "img/img_bingo_hertz.png"), align = "center"))
         ), 
         "Volt" = fluidRow(
           column(12, div(img(src= "img/img_bingo_volt.png"), align = "center"))
         ), 
         "Watt" = fluidRow(
           column(12, div(img(src= "img/img_bingo_watt.png"), align = "center"))
         ),
         "Ohm" = fluidRow(
           column(12, div(img(src= "img/img_bingo_ohm.png"), align = "center"))
         ))
})

#------------
# production
#------------
output$hyp_prod <- renderAmCharts({
  input$hyp_scenario
  # input$go_hyp_prod
  isolate({
    # res <- getProductionHypothesis(data = hyp_prod, nodes = input$area_hyp_prod, sce_prod = sce_prod, scenario = input$hyp_scenario)
    res <- getProductionHypothesis(data = hyp_prod, nodes = "fr", sce_prod = sce_prod, scenario = input$hyp_scenario)
    res <- res[, c("date", order_hyp_prod)]
    
    gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                     stack_type = ifelse(isolate(input$stack_hyp_prod) == "regular", "regular", "100"), legend = TRUE,
                     groups_color = unname(cl_hyp_prod[colnames(res)[-1]]), 
                     # main = paste0("Évolution du parc installé (scénario ", input$hyp_scenario, ")"),
                     main = "Évolution du parc installé",
                     zoom = TRUE, show_values = FALSE, 
                     ylab = ifelse(isolate(input$stack_hyp_prod) == "regular", "GW", "%"),
                     labelRotation = 45, legendPosition = "left", autoMargins = FALSE, 
                     marginLeft = 100, marginTop = 60, marginRight = 60, marginBottom = 60)  %>%
      setExport(enabled = FALSE, menu = ramcharts_menu_obj)
    
    gr@otherProperties$thousandsSeparator <- " "
    
    gr@graphs <- lapply(gr@graphs, function(x){
      x$balloonText <- gsub("[[value]]", "[[value]] GW ([[percents]]%)", fixed = TRUE, x$balloonText)
      x
    })
    
    if(isolate(input$stack_hyp_prod) == "regular"){
      gr@legend$valueText <- "[[value]] GW"
    } else {
      gr@legend$valueText <- "[[percents]]%"
    }
   
    gr@legend$unit <- "GW"
    gr@legend$reversedOrder <- TRUE

    gr
    
  })
})

observe({
  session$sendCustomMessage(type = 'rAmCharts_update_stack',
                            message = list(input$stack_hyp_prod, "hyp_prod"))
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
    groups_color = unname(usage_col[colnames(res)[-1]])
  }
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = ifelse(isolate(input$stack_hyp_conso) == "regular", "regular", "100"), legend = TRUE,
                   groups_color = groups_color, 
                   # main = paste0("Hypothèses de consommation (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution de la consommation",
                   zoom = ifelse(type == "Branche", FALSE, TRUE), 
                   show_values = FALSE, ylab = ifelse(isolate(input$stack_hyp_conso) == "regular", "TWh", "%"),
                   # horiz = ifelse(type == "Branche", TRUE, FALSE),
                   labelRotation = 45, legendPosition = "bottom", autoMargins = FALSE, 
                   marginLeft = 100, marginTop = 60, marginRight = 60, marginBottom = 60)  %>%
    setExport(enabled = FALSE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  
  if(type == "Branche"){
    gr <- setChartCursor(.Object = gr, valueZoomable = TRUE, 
                         valueLineEnabled = TRUE, zoomable = TRUE, 
                         valueLineBalloonEnabled = TRUE, valueBalloonsEnabled = FALSE)
  }
  
  gr@graphs <- lapply(gr@graphs, function(x){
    x$balloonText <- gsub("[[value]]", "[[value]] TWh ([[percents]]%)", fixed = TRUE, x$balloonText)
    x
  })
  
  if(isolate(input$stack_hyp_conso) == "regular"){
    gr@legend$valueText <- "[[value]] TWh"
  } else {
    gr@legend$valueText <- "[[percents]]%"
  }
  
  gr@legend$unit <- "TWh"
  
  gr
})

observe({
  session$sendCustomMessage(type = 'rAmCharts_update_stack',
                            message = list(input$stack_hyp_conso, "hyp_conso"))
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
  res <- res[, c("date", order_hyp_interco)]
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_interco[1:(ncol(res) - 1)]), 
                   # main = paste0("Évolution des capacités d'import (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution des capacités d'import",
                   zoom = TRUE, show_values = FALSE, ylab = "GW",
                   labelRotation = 45, ylim = c(0, 35))  %>%
    setExport(enabled = FALSE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  gr@legend$reversedOrder <- TRUE
  
  gr
})

output$hyp_inter_export <- renderAmCharts({
  
  res <- res_inter()$export
  res <- res[, c("date", order_hyp_interco)]
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_interco[1:(ncol(res) - 1)]), 
                   # main = paste0("Évolution des capacités d'export (scénario ", input$hyp_scenario, ")"),
                   main = "Évolution des capacités d'export",
                   zoom = TRUE, show_values = FALSE, ylab = "GW",
                   labelRotation = 45, ylim = c(0, 35))  %>%
    setExport(enabled = FALSE, menu = ramcharts_menu_obj)
  
  gr@otherProperties$thousandsSeparator <- " "
  gr@legend$reversedOrder <- TRUE
  
  gr
})


# observe({
#   session$sendCustomMessage(type = 'rAmCharts_update_stack',
#                             message = list(input$stack_hyp_inter, "hyp_inter_import"))
#   
#   session$sendCustomMessage(type = 'rAmCharts_update_stack',
#                             message = list(input$stack_hyp_inter, "hyp_inter_export"))
# })


#------------
# co2
#------------

output$hyp_co2<- renderAmCharts({
  
  tmp <- data.frame(date = colnames(hyp_co2)[-1], historique = t(data.frame(hyp_co2[scenario %in% input$hyp_scenario, ][, scenario := NULL]))[, 1])
  tmp <- tmp[!is.na(tmp$historique),]
  tmp$scenario <- tmp$historique
  tmp$scenario[1:5] <- NA
  tmp$historique[-c(1:5)] <- NA

  gr <- amBarplot(x = "date", y = c("scenario", "historique"), data = tmp,
            stack_type = "regular", legend = TRUE,
            # main = paste0("Évolution des émissions de CO2 en France (scénario ", input$hyp_scenario, ")"),
            main = "Évolution des émissions de CO2 en France",
            zoom = TRUE, show_values = FALSE,
            ylab = "Millions de tonnes (Mt)", horiz = FALSE,
            labelRotation = 45, theme = "pattern", creditsPosition = "top-right")  %>%
    setExport(enabled = FALSE, menu = ramcharts_menu_obj)
  
  gr@legend$reversedOrder <- TRUE
  
  gr@graphs <- lapply(gr@graphs, function(x){
    x$fillColors <- NULL
    x$legendColor <- NULL
    x
  })
  
  gr
})


#-------------
# bilan
#-------------

data_bilan <- reactive({
  getBilan(hyp_bilan, hyp_co2, table_couleur_bilan, scenario = input$hyp_scenario)
})

output$bilan_1_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  a <- amPie(data = data_bilan$pie_conso_2025, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 40, radius = 80,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
  a@otherProperties$pullOutRadius <- "0%"
  a
})

output$bilan_1_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2025, show_values = TRUE, 
                         innerRadius = 80, radius = 120, 
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
                             size = 14,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_1 <- renderUI({
  data_bilan <- data_bilan()
  div(
    fluidRow(
      column(4, div(paste("CO2", data_bilan$co2_2025, "Mt"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("leaf"), paste(data_bilan$enr_2025, "%"), style = "position: absolute; z-index : 100; width:90%;border-radius: 10px; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("industry"), paste(data_bilan$nuc_2025, "%"), style = "position: absolute; z-index : 100; width:90%;border-radius: 10px; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
    ), style = "width:96%;"
  )
})

output$bilan_2_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  a <- amPie(data = data_bilan$pie_conso_2030, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 40, radius = 80,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
  a@otherProperties$pullOutRadius <- "0%"
  a
})

output$bilan_2_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2030, show_values = TRUE, 
                         innerRadius = 80, radius = 120, 
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
                             size = 14,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_2 <- renderUI({
  data_bilan <- data_bilan()
  div(
    fluidRow(
      column(4, div(paste("CO2", data_bilan$co2_2030, "Mt"), style = "position: absolute; z-index : 100;width:90%; border-radius: 10px;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("leaf"), paste(data_bilan$enr_2030, "%"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("industry"), paste(data_bilan$nuc_2030, "%"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
    ), style = "width:96%;"
  )
})

output$bilan_3_1 <- renderAmCharts({
  data_bilan <- data_bilan()
  a <- amPie(data = data_bilan$pie_conso_2035, show_values = TRUE, 
        creditsPosition = "bottom-left",
        innerRadius = 40, radius = 80,  legend = FALSE,
        labelText =  "[[value]]",
        labelRadius = -20, bringToFront = TRUE,
        labelColor = "white")
  a@otherProperties$pullOutRadius <- "0%"
  a
})

output$bilan_3_2 <- renderAmCharts({
  data_bilan <- data_bilan()
  suppressWarnings(amPie(data = data_bilan$pie_prod_2035, show_values = TRUE, 
                         innerRadius = 80, radius = 120, 
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
                             size = 14,
                             color = "#404040",
                             x = 0,
                             align = "center",
                             y = 190))
  ))
})


output$info_bilan_3 <- renderUI({
  data_bilan <- data_bilan()
  div(
    fluidRow(
      column(4, div(paste("CO2", data_bilan$co2_2035, "Mt"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px;background-color: #ACA4A4; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("leaf"), paste(data_bilan$enr_2035, "%"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px; background-color: #6DD19B; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center")),
      column(4, div(icon("industry"), paste(data_bilan$nuc_2035, "%"), style = "position: absolute; z-index : 100; width:90%; border-radius: 10px; background-color: #F8D71E; margin-top: -120px; font-size:20px;font-weight: bold;color: white;", align = "center" ))
    ), style = "width:96%;"
  )
})