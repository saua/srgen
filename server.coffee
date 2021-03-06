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
app.locals.config = config

app.set 'view engine', 'jade'

asset = {}
connectAssets = require('connect-assets')
app.use connectAssets(src: path.join(__dirname, 'src'), helperContext: asset)
asset.js.root = asset.css.root = asset.img.root = ''
app.locals(asset)

app.use app.router

webPaths = [ '/character/' ]
index = (req, res) -> res.render 'index'

# This is all our HTML
app.get '/', index
app.get("#{wp}*", index) for wp in webPaths
app.get '/partials/:name', (req, res) ->
  res.render "partials/#{req.params.name}"

if config.web.useManifest
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
    result += jsPaths 'client/app.js'
    result += cssPath 'lib/css/bootstrap.css'
    result += cssPath 'lib/css/app.css'
    partials = ( partial.substring(0,partial.lastIndexOf('.jade')) for partial in fs.readdirSync path.join(__dirname, 'views', 'partials') )
    result += "/partials/#{partial}\n" for partial in partials
    result += '//fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,400,700\n'
    result += '\nNETWORK:\n/api\n'
    # having this in network is non-ideal, but once it's cached the browser *should* use it in offline mode as well
    result += '//themes.googleusercontent.com/static/fonts/\n'
    if config.web.googleAnalytics.trackingId
      result += '//www.google-analytics.com/\n//ssl.google-analytics.com/\n'

    result += '\nFALLBACK:\n'
    result += ["#{wp} /\n" for wp in webPaths ].join('\n') + '\n'
    return result
  manifest = buildManifest()

  app.get '/srgen.appcache', (req, res) ->
    res.set 'Content-Type', 'text/cache-manifest'
    res.send manifest
else
  app.get '/srgen.appcache', (req, res) ->
    res.status(404).send 'No Manifest'

app.listen config.web.port, ->
  console.log "Listening on #{config.web.port}"
  console.log "Mode: #{config.env}"
  console.log "URL: #{config.web.URL}"