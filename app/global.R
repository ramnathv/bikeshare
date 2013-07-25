## @knitr loadLibraries
require(RJSONIO); require(rCharts); require(RColorBrewer); require(httr)
options(stringsAsFactors = F)

## @knitr getNetworks
getNetworks <- function(){
  require(httr)
  if (!file.exists('networks.json')){
    url <- 'http://api.citybik.es/networks.json'
    dat <- content(GET(url))
    writeLines(dat, 'networks.json')
  }
  networks <- RJSONIO::fromJSON('networks.json')
  nms <- lapply(networks, '[[', 'name')
  names(networks) <- nms
  return(networks)
}

## @knitr getNetworks2
networks <- getNetworks()

## @knitr getData
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

## @knitr getCenter
getCenter <- function(nm, networks){
  net_ = networks[[nm]]
  lat = as.numeric(net_$lat)/10^6;
  lng = as.numeric(net_$lng)/10^6;
  return(list(lat = lat, lng = lng))
}


## @knitr plotMap
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
