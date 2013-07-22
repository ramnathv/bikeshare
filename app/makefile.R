payload = create_gist(
  filenames = c('ui.R', 'global.R', 'server.R', 'networks.json'), 
  description = 'Bike Share Shiny App'
)

post_gist(payload, viewer = 'http://gist.github.com/ramnathv/')