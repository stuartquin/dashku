repl              = require 'repl'
ss                = require 'socketstream'
internals         = require './server/internals'

ss.session.store.use 'redis', ss.api.app.config.redis

# Use redis for pubsub
ss.publish.transport.use 'redis', ss.api.app.config.redis

repl.start("> ").context.ss = ss