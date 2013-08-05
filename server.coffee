express = require 'express'
passport = require 'passport'
path = require 'path'

config = require './src/server/config'

app = express()
env = app.get('env')

app.set 'view engine', 'jade'


app.use require('connect-assets')(src: path.join(__dirname, 'src'))
# we want to handle full paths in connect-assets
js.root = css.root = img.root = ''

app.use app.router

if env == 'development'
  app.use express.errorHandler()
  app.locals.pretty = true
  express.logger 'dev'

index = (req, res) -> res.render 'index'

app.get '/', index
app.get '/partials/:name', (req, res) ->
  res.render "partials/#{req.params.name}"

app.get '*', index

app.listen config.web.port, ->
  console.log "Listening on #{config.web.port}"
  console.log "Mode: #{env}"
  console.log "URL: #{config.web.URL}"