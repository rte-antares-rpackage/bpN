$(function() {
  $(document).on({
    
    'shiny:busy': function(event) {
      $('#import_busy').css("visibility", "visible");
    },
    
    'shiny:idle': function(event) {
      $('#import_busy').css("visibility", "hidden");
    }
  });
  
});


// for double pie on bilan
AmCharts.addInitHandler(function(chart) {
  
  // init holder for nested charts
  if (AmCharts.nestedChartHolder === undefined)
    AmCharts.nestedChartHolder = {};
  if (chart.bringToFront === true) {
    chart.addListener("init", function(event) {
      // chart inited
      if(event.chart.be_init === undefined){
        var chart = event.chart;
              
        var div = chart.div;
        div.setAttribute('style', "width : 500px; height	: 400px; position: absolute; top: 0;left: 0;");
      
        var parent = div.parentNode;

        // add to holder
        if (AmCharts.nestedChartHolder[parent] === undefined)
          AmCharts.nestedChartHolder[parent] = [];
        AmCharts.nestedChartHolder[parent].push(chart);
      
        // add mouse mouve event
        chart.div.addEventListener('mousemove', function() {
          
          // calculate current radius
          var x = Math.abs(chart.mouseX - (chart.realWidth / 2));
          var y = Math.abs(chart.mouseY - (chart.realHeight / 2));
          var r = Math.sqrt(x*x + y*y);
          
          // check which chart smallest chart still matches this radius
          var smallChart;
          var smallRadius;
          for(var i = 0; i < AmCharts.nestedChartHolder[parent].length; i++) {
            var checkChart = AmCharts.nestedChartHolder[parent][i];
            
            if((checkChart.radiusReal < r) || (smallRadius < checkChart.radiusReal)) {
              checkChart.div.style.zIndex = 1;
            }else {
              if (smallChart !== undefined && smallChart.div.id.substring(0, 7) === checkChart.div.id.substring(0, 7)){
                smallChart.div.style.zIndex = 1;
              }
              checkChart.div.style.zIndex = 2;
              smallChart = checkChart;
              smallRadius = checkChart.radiusReal;
            }
          }
        }, false);
        }
        event.chart.be_init = true;
    });
  }
}, ["pie"]);


// This recieves messages of type "testmessage" from the server.
Shiny.addCustomMessageHandler("rAmCharts_update_stack",
  function(params) {
    var chart = getAmChart(params[1]);
    if(chart !== undefined){
      chart.valueAxes[0].stackType = params[0];
      chart.validateNow();
    }
  }
);

