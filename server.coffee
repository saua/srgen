express = require 'express'

app = express()

app.set 'view engine', 'jade'

# set up connect-assets
app.use require('connect-assets')(src: __dirname + '/src')
# we want to handle full paths
js.root = css.root = img.root = ''
# required by bootstrap
img 'lib/img/glyphicons-halflings-white.png'
img 'lib/img/glyphicons-halflings.png'
# app.use express.static __dirname + '/public'

app.get '/', (req, res) ->
  res.render 'index'

app.configure 'development', ->
  app.use express.errorHandler()
  app.locals.pretty = true

port = process.env.PORT || 8000;
app.listen port, ->
  console.log "Listening on #{port}"