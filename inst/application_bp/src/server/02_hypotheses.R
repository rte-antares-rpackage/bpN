output$hyp_prod <- renderAmCharts({
  
  input$go_hyp_prod
  isolate({
    res <- getProductionHypothesis(data = hyp_prod, nodes = input$area_hyp_prod, sce_prod = sce_prod, scenario = input$hyp_scenario)
    
    amBarplot(x = "date", y = colnames(res)[-1], data = res, 
              stack_type = "regular", legend = TRUE,
              groups_color = unname(cl_hyp_prod[colnames(res)[-1]]), main = paste0("Evolution du parc installé (scénario ", input$hyp_scenario, ")"),
              zoom = TRUE, export = TRUE, show_values = FALSE,
              ylab = "MW",
              labelRotation = 45, legendPosition = "bottom", height = "800")
  })
})

output$hyp_conso <- renderAmCharts({
  
    res <- getConsoHypothesis(data = hyp_conso, sce_prod = sce_prod, scenario = input$hyp_scenario)
    
    amBarplot(x = "date", y = colnames(res)[-1], data = res, 
              stack_type = "regular", legend = TRUE,
              groups_color = unname(cl_hyp_prod[1:(ncol(res) - 1)]), 
              main = "Hypothèses de consommation",
              zoom = TRUE, export = TRUE, show_values = FALSE,
              ylab = "TWh",
              labelRotation = 45, legendPosition = "bottom", height = "800")
})