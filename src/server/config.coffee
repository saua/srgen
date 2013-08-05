config = {}

config.web = {}
config.web.port = process.env.PORT || 3000
config.web.URL = process.env.URL || "http://localhost:#{config.web.port}/"

config.express = {}
config.express.session =
  cookieSecret: process.env.COOKIE_SECRET || 'not really secret' # ;-)

module.exports = config;