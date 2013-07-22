## @knitr server
require(shiny)
require(rCharts)
shinyServer(function(input, output, session){
  output$map_container <- renderMap({
    plotMap(input$network)
  })
})
