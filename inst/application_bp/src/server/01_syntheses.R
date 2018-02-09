observe({
  if(input[['nav-id']]  == "Synthèse"){
      updateNavbarPage(session, inputId = "synth_tab", selected = "Les scénarios")
  }
})

observe({
  if(input[['synth_tab']]  == "Ampère"){
    updateNavbarPage(session, inputId = "synth_tab_amp", selected = "Principe")
  }
})

observe({
  if(input[['synth_tab']]  == "Hertz"){
    updateNavbarPage(session, inputId = "synth_tab_hertz", selected = "Principe")
  }
})

observe({
  if(input[['synth_tab']]  == "Volt"){
    updateNavbarPage(session, inputId = "synth_tab_volt", selected = "Principe")
  }
})

observe({
  if(input[['synth_tab']]  == "Watt"){
    updateNavbarPage(session, inputId = "synth_tab_watt", selected = "Principe")
  }
})