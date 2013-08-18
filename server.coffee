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

webPaths = [ '/character/' ]

if config.web.useManifest
  additionalURLs = [ '//fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,400,700' ]
  buildManifest = () ->
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
    partials = ( partial.substring(0,partial.lastIndexOf('.jade')) for partial in fs.readdirSync path.join(__dirname, 'views', 'partials') )
    result += "/partials/#{partial}\n" for partial in partials
    result += additionalURL + '\n' for additionalURL in additionalURLs
    result += '''


              NETWORK:
              /api

              FALLBACK:

              '''
    result += ["#{wp} /\n" for wp in webPaths ].join('\n') + '\n'
    return result
  manifest = buildManifest()

  app.get '/srgen.appcache', (req, res) ->
    res.set 'Content-Type', 'text/cache-manifest'
    res.send manifest
else
  app.get '/srgen.appcache', (req, res) ->
    res.status(404).send 'No Manifest'

app.get("#{wp}*", index) for wp in webPaths

app.listen config.web.port, ->
  console.log "Listening on #{config.web.port}"
  console.log "Mode: #{config.env}"
  console.log "URL: #{config.web.URL}"