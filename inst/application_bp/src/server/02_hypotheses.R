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
                     groups_color = unname(cl_hyp_prod[colnames(res)[-1]]), 
                     main = paste0("Evolution du parc installé (scénario ", input$hyp_scenario, ")"),
                     zoom = TRUE, export = TRUE, show_values = FALSE,
                     ylab = "MW",
                     labelRotation = 45, legendPosition = "bottom", height = "800")
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
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_prod[1:(ncol(res) - 1)]), 
                   main = paste0("Hypothèses de consommation (scénario ", input$hyp_scenario, ")"),
                   zoom = ifelse(type == "Branche", FALSE, TRUE), 
                   export = TRUE, show_values = FALSE,
                   ylab = "TWh",
                   # horiz = ifelse(type == "Branche", TRUE, FALSE),
                   labelRotation = 45, legendPosition = "bottom", height = "800")
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
                   main = paste0("Evolution des capacités d'import (scénario ", input$hyp_scenario, ")"),
                   zoom = TRUE, export = TRUE, show_values = FALSE,
                   ylab = "MW",
                   labelRotation = 45, legendPosition = "bottom", height = "800")
  gr@otherProperties$thousandsSeparator <- " "
  gr
})

output$hyp_inter_export <- renderAmCharts({
  
  res <- res_inter()$export
  
  gr  <- amBarplot(x = "date", y = colnames(res)[-1], data = res, 
                   stack_type = "regular", legend = TRUE,
                   groups_color = unname(cl_hyp_interco[1:(ncol(res) - 1)]), 
                   main = paste0("Evolution des capacités d'export (scénario ", input$hyp_scenario, ")"),
                   zoom = TRUE, export = TRUE, show_values = FALSE,
                   ylab = "MW",
                   labelRotation = 45, legendPosition = "bottom", height = "800")
  gr@otherProperties$thousandsSeparator <- " "
  gr
})