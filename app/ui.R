## @knitr ui
require(shiny)
require(rCharts)
networks <- getNetworks()
shinyUI(bootstrapPage( 
  tags$link(href='style.css', rel='stylesheet'),
  tags$script(src='app.js'),
  includeHTML('www/credits.html'),
  selectInput('network', '', sort(names(networks)), 'citibikenyc'),
  mapOutput('map_container')
))