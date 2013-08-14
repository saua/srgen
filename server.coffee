express = require 'express'
path = require 'path'
fs = require 'fs'

config = require './src/server/config'

app = express()

if config.isDevelopment
  app.use express.errorHandler()
  app.use express.logger 'dev'

app.locals.pretty = config.web.prettyPrint
app.locals.useManifest = config.web.useManifest

app.set 'view engine', 'jade'

asset = {}
connectAssets = require('connect-assets')
app.use connectAssets(src: path.join(__dirname, 'src'), helperContext: asset)
asset.js.root = asset.css.root = asset.img.root = ''
app.locals(asset)

app.use app.router

index = (req, res) -> res.render 'index'

app.get '/', index
app.get '/partials/:name', (req, res) ->
  res.render "partials/#{req.params.name}"

if config.web.useManifest
  app.get '/srgen.appcache', (req, res) ->
    result = '''
             CACHE MANIFEST

             SETTINGS:
             prefer-online

             CACHE:
             /

             '''
    jsPaths = (js) ->
      connectAssets.instance.compileJS(js).join('\n')+'\n'
    cssPath = (css) ->
      connectAssets.instance.compileCSS(css) + '\n'
    # currently this list needs to be updated by hand
    # maybe this could be parsed out of index.jade somehow, but it's not worth it yet.
    result += jsPaths 'lib/js/angular.js'
    result += jsPaths 'lib/js/ui-bootstrap-tpls-0.5.0.js'
    result += jsPaths 'client/app.js'
    result += cssPath 'lib/css/bootstrap.css'
    result += cssPath 'lib/css/app.css'
    partials = fs.readdirSync path.join(__dirname, 'views', 'partials')
    result += "/partials/#{partial.substring(0,partial.lastIndexOf('.jade'))}\n" for partial in partials
    result += '''

              NETWORK:
              /api

              FALLBACK:
              / /
              '''
    console.log result
    res.set 'Content-Type', 'text/cache-manifest'
    res.send result
else
  app.get '/srgen.appcache', (req, res) ->
    res.status(404).send 'No Manifest'

app.get '*', index

app.listen config.web.port, ->
  console.log "Listening on #{config.web.port}"
  console.log "Mode: #{config.env}"
  console.log "URL: #{config.web.URL}"