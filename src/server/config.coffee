config = {}

config.env = process.env.NODE_ENV
config.isProduction = config.env == 'production'
config.isDevelopment = config.env == 'development'

config.web = {}
config.web.port = process.env.PORT || 3000
config.web.URL = process.env.URL || "http://localhost:#{config.web.port}/"
config.web.useManifest = process.env.USE_MANIFEST || config.isProduction

config.express = {}
config.express.session =
  cookieSecret: process.env.COOKIE_SECRET || 'not really secret' # ;-)

module.exports = config;