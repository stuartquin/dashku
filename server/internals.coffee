# Internals, where all the config is loaded and set into the application
ss = require 'socketstream'

app = 
  models      : {}
  controllers : {}
  schemas     : {}
  helpers     : {}

app.config = require('./config')[ss.env]

require("./db") app
require("./helpers") app

require("./controllers/dashboard") app
require("./controllers/widget") app

ss.api.add 'app', app