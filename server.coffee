express = require 'express'
path = require 'path'

config = require './src/server/config'

app = express()
env = app.get('env')

if env == 'development'
  app.use express.errorHandler()
  app.locals.pretty = true
  app.use express.logger 'dev'

app.set 'view engine', 'jade'

asset = {}
connectAssets = require('connect-assets')(src: path.join(__dirname, 'src'), helperContext: asset)
app.use connectAssets
asset.js.root = asset.css.root = asset.img.root = ''
app.use (req, res, next) ->
  res.locals asset
  next()

app.use app.router

index = (req, res) -> res.render 'index'

app.get '/', index
app.get '/partials/:name', (req, res) ->
  res.render "partials/#{req.params.name}"

app.get '*', index

app.listen config.web.port, ->
  console.log "Listening on #{config.web.port}"
  console.log "Mode: #{env}"
  console.log "URL: #{config.web.URL}"