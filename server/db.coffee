# npm modules
mongoose   = require 'mongoose'
redis      = require 'redis'
ss         = require 'socketstream'

module.exports = (app) ->

  # Redis-related configuration
  app.Redis = redis.createClient app.config.redis.port, app.config.redis.host
  app.Redis.auth(app.config.redis.pass) if ss.env is 'production'
  
  # MongoDB-related configuration
  mongoose.connect "mongodb://#{app.config.db}"
  require("#{__dirname}/models/user.coffee") app
  require("#{__dirname}/models/widget.coffee") app
  require("#{__dirname}/models/dashboard.coffee") app
  require("#{__dirname}/models/widgetTemplate.coffee") app