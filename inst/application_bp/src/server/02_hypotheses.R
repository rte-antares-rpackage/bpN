output$hyp_prod <- renderAmCharts({
  
  input$go_hyp_prod
  isolate({
    res <- getProductionHypothesis(data = hyp_prod, nodes = input$area_hyp_prod, enr = input$enr_hyp_prod, thermal = input$th_hyp_prod)
    
    amBarplot(x = "date", y = colnames(res)[-1], data = res, 
              stack_type = "regular", legend = TRUE,
              groups_color = unname(cl_hyp_prod[colnames(res)[-1]]), main = "Hypothèses de production",
              zoom = TRUE, export = TRUE, show_values = FALSE,
              ylab = "Capacités (MW)",
              labelRotation = 45, legendPosition = "bottom", height = "800")
  })
})