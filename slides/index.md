---
title: Bike Sharing
subtitle: Visualized
author: Ramnath Vaidyanathan
github: {user: ramnathv, repo: bikeshare, branch: "gh-pages"}
framework: io2012
mode: selfcontained
hitheme: solarized_light
assets:
  css: "http://fonts.googleapis.com/css?family=PT+Sans"
  jshead: lazyload.min.js
url: {lib: "../libraries"}
widgets: [bootstrap]
--- 

## Building Interactive Visualizations

> 1. Get Data.
> 2. Create Visualization.
> 3. Wrap in Shiny/AngularJS!

<style>
.title-slide {
  background: url(http://www.clipular.com/c?11569005=BeLkjndQT6SwPyFOh-ybbS9Q-V0&f=.png);
  opacity: 0.5;
}
</style>

*** =pnotes

A couple of months ago I had posted an interesting application of using rCharts and Shiny to visualize the CitiBike system in NYC. I had always wanted to write a tutorial about its inner workings, so that it would be useful to others looking to build similar visualizations, and I finally got around to doing it. Along the way, I managed to extend the visualization to around 100 bike sharing systems across the world. The final application can be viewed [here](http://glimmer.rstudio.com/ramnathv/BikeShare). 

--- .segue .dark

## Get Data




--- .bigger

## Fetch Data

<style>slide.bigger pre {font-size: 24px; line-height: 1.5em;}</style>


```r
network <- 'citibikenyc'
url = sprintf('http://api.citybik.es/%s.json', network)
bike = fromJSON(content(GET(url)))
```


*** =pnotes

We use the API provide by [CitiBikes]('http://api.citybik.es/') to fetch our data. There are three steps

1. `GET` fetches the data using a GET request.
2. `content` extracts the json content from the data.
3. `fromJSON` converts it into an R object (list).

---

## Inspect Data


```
$name
[1] "W 52 St & 11 Ave"

$timestamp
[1] "2013-07-25T23:36:57.281368"

$number
[1] 72

$free
[1] 30

$bikes
[1] 8

$address
[1] "W 52 St & 11 Ave"
```


--- .bigger

## Add FillColor


```r
bike <- lapply(bike, function(station){within(station, { 
  fillColor = cut(
    as.numeric(bikes)/(as.numeric(bikes)+as.numeric(free)), 
    breaks = c(0, 0.20, 0.40, 0.60, 0.80, 1), 
    labels = brewer.pal(5, 'RdYlGn'),
    include.lowest = TRUE
  )})
})
```


--- .bigger

## Add Popup


```r
bike <- lapply(bike, function(station){within(station, { 
   popup = iconv(whisker::whisker.render(
'<b>{{name}}</b><br>
<b>Free Docks: </b> {{free}} <br>
<b>Available Bikes:</b> {{bikes}}
<b>Retrieved At: {{timestamp}}</b>'
   ), from = 'latin1', to = 'UTF-8')})
}) 
```


*** =pnotes

Here, we loop through all the stations, and add a popup that displays fields of interest. More specifically, we

1. Specify a `mustache` template and render it with data for each station. 
2. Convert the resulting string to `UTF-8` using `iconv` to avoid encoding issues in the browser.

--- .bigger

## Sample Popup

### HTML


```
<b>W 52 St &amp; 11 Ave</b><br>
<b>Free Docks: </b> 30 <br>
<b>Available Bikes:</b> 8
<b>Retrieved At: 2013-07-25T23:36:57.281368</b>
```


### View

<b>W 52 St &amp; 11 Ave</b><br>
<b>Free Docks: </b> 30 <br>
<b>Available Bikes:</b> 8
<b>Retrieved At: 2013-07-25T23:36:57.281368</b>


---

<a class='example'>getData</a>


```r
getData <- function(network = 'citibikenyc'){
  require(httr)
  url = sprintf('http://api.citybik.es/%s.json', network)
  bike = fromJSON(content(GET(url)))
  lapply(bike, function(station){within(station, { 
   fillColor = cut(
     as.numeric(bikes)/(as.numeric(bikes) + as.numeric(free)), 
     breaks = c(0, 0.20, 0.40, 0.60, 0.80, 1), 
     labels = brewer.pal(5, 'RdYlGn'),
     include.lowest = TRUE
   ) 
   popup = iconv(whisker::whisker.render(
      '<b>{{name}}</b><br>
        <b>Free Docks: </b> {{free}} <br>
         <b>Available Bikes:</b> {{bikes}}
        <p>Retreived At: {{timestamp}}</p>'
   ), from = 'latin1', to = 'UTF-8')
   latitude = as.numeric(lat)/10^6
   longitude = as.numeric(lng)/10^6
   lat <- lng <- NULL})
  })
}
```



--- .segue .nobackground .dark

## Create Visualization

--- .bigger

## Basic Map


```r
require(rCharts)
L1 <- Leaflet$new()
L1$tileLayer(provider = 'Stamen.TonerLite')
L1$setView(c(40.73029, -73.99076), 13)
L1$set(width = 1200, height = 600)
```


*** =pnotes

1. Create an instance of the Leaflet class.
2. Set the provider of tileLayers to 'Stamen.TonerLite'. Check [here](https://github.com/leaflet-extras/leaflet-providers) for a list of providers.
3. Set center of map and zoom level (1 = world, 18 = street)
4. Set width and height of the map.

---

<iframe data-src='maps/map1.html' seamless onload=lzld(this)></iframe>

--- .bigger

## Add Stations


```r
data_ <- getData('citibikenyc')
L1$geoJson(toGeoJSON(data_))
```


---

<iframe data-src='maps/map2.html' seamless onload=lzld(this)></iframe>

--- .bigger

## Style Points


```r
L1$geoJson(toGeoJSON(data_), 
  pointToLayer =  "#! function(feature, latlng){
    return L.circleMarker(latlng, {
      radius: 4,
      fillColor: feature.properties.fillColor || 'red',    
      color: '#000',
      weight: 1,
      fillOpacity: 0.8
    })
  }!#"
)
L1$save('maps/map3.html', cdn = TRUE)
```


---

<iframe data-src='maps/map3.html' seamless onload=lzld(this)></iframe>

--- .bigger

## Add Popup


```r
L1$geoJson(toGeoJSON(data_), 
  onEachFeature = '#! function(feature, layer){
    layer.bindPopup(feature.properties.popup)
  } !#',
  pointToLayer =  "#! function(feature, latlng){
    return L.circleMarker(latlng, {
      radius: 4,
      fillColor: feature.properties.fillColor || 'red',    
      color: '#000',
      weight: 1,
      fillOpacity: 0.8
    })
  } !#"
)
L1$save('maps/map4.html', cdn = TRUE)
```


---

<iframe data-src='maps/map4.html' seamless onload=lzld(this)></iframe>

---

<a class='example'>plotMap</a>


```r
plotMap <- function(network = 'citibikenyc', width = 1600, height = 800){
  data_ <- getData(network); center_ <- getCenter(network, networks)
  L1 <- Leaflet$new()
  L1$tileLayer(provider = 'Stamen.TonerLite')
  L1$set(width = width, height = height)
  L1$setView(c(center_$lat, center_$lng), 13)
  L1$geoJson(toGeoJSON(data_), 
    onEachFeature = '#! function(feature, layer){
      layer.bindPopup(feature.properties.popup)
    } !#',
    pointToLayer =  "#! function(feature, latlng){
      return L.circleMarker(latlng, {
        radius: 4,
        fillColor: feature.properties.fillColor || 'red',    
        color: '#000',
        weight: 1,
        fillOpacity: 0.8
      })
    } !#")
  L1$enablePopover(TRUE)
  L1$fullScreen(TRUE)
  return(L1)
}
```



--- .segue .dark .nobackground

## Wrap in Shiny

*** =pnotes

Now that we have successfully visualized the bike sharing system for NYC, we can get to the exciting task of wrapping this up in a Shiny application, where the user can interactively choose the bike sharing system, whose availabilities they want to visualize. Before, we can do that, we need the names of these systems to passed to `plotMap`. Thankfully, the [http://api.citybik.es/](CityBikes) API provides easy access to this. The `getNetworks` function retrieves this data.

This is the easiest part of the whole tutorial. Shiny requires two files `ui.R` and `server.R`, that contain the UI and server logic respectively.


--- .bigger

## UI


```r
require(shiny)
require(rCharts)
networks <- getNetworks()
shinyUI(bootstrapPage( 
  selectInput('network', '', sort(names(networks)), 'citibikenyc'),
  mapOutput('map_container')
))
```


*** =pnotes

For the UI, I make use of a basic bootstrap page that ships with Shiny. I use a `selectInput` for users to select the network they want to visualize, and populate it with an alphabetically sorted list of names of all the networks, initialized to `citibikenyc`. I use the `mapOutput` function which adds a div container named `map_container` that houses the map.

--- .bigger

## Server


```r
require(shiny)
require(rCharts)
shinyServer(function(input, output, session){
  output$map_container <- renderMap({
    plotMap(input$network)
  })
})
```


*** =pnotes

The server side code is even simpler than the UI and merely wraps the `plotMap` call inside `renderMap`, and passes the name of the network chosen by the user, `input$network` in place of the hard-coded `citibikenyc`.


















