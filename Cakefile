# Cakefile
 
# If you move to a new Redis DB, you may want to run this function
# to regenerate the API Key database
regenerateApiKeyDb = (cb) ->
  ss               = require 'socketstream'
  internals        = require './server/internals'
  User             = ss.api.app.models.User
  Redis            = ss.api.app.Redis
  User.find {}, (err, docs) ->
    if !err
      if docs.length > 0
        for doc in docs
          Redis.hset "apiKeys", doc.apiKey, doc._id, Redis.print
          if docs.indexOf doc is docs.length-1
            cb 0
      else
        console.log "There are no users in the database, no need to regenerate the API key database"
        cb 0

# This populates the WidgetTemplates collection with Widget Templates
populateWidgetTemplates = (cb) ->
  fs                    = require 'fs'
  ss                    = require 'socketstream'
  internals             = require './server/internals'
  WidgetTemplate        = ss.api.app.models.WidgetTemplate
  console.log "Clearing the WidgetTemplates collection"
  WidgetTemplate.remove {}, (err) ->
    if err is null
      fs.readdir "#{__dirname}/server/seed/widgetTemplates/", (err, files) ->
        if !err and files
          count = 0
          for file in files
            widgetTemplate = new WidgetTemplate require "#{__dirname}/server/seed/widgetTemplates/#{file}"
            widgetTemplate.save (err,doc) -> 
              count++
              if err? then console.log "There was an error populating the WidgetTemplate collection"
              if count is files.length-1
                console.log "WidgetTemplate collection populated"
                cb 0
    else
      console.log "There was an error clearing the WidgetTemplates collection"
      cb 1

# TODO - figure out a way to automate this
files = [
  "server/models/user.coffee"
  "server/rpc/authentication.coffee"
  "server/rpc/dashboard.coffee"
  "server/rpc/general.coffee"
  "server/rpc/widget.coffee"
  "server/rpc/widgetTemplate.coffee"
]

test = (cb) ->
  mocha                 = require 'mocha'
  process.env["SS_ENV"] = "test"
  ss                    = require 'socketstream'
  internals             = require './server/internals'
  Mocha = new mocha
  for file in files
    Mocha.addFile "test/#{file.replace('.coffee','_test.coffee')}"
  Mocha.run (res) ->
    cb res if cb?

task 'test', 'run unit tests for the project', ->
  test process.exit

task 'regenerateApiKeyDb', 'Compiles the SocketStream assets, and copies them to a fixed path', ->
  regenerateApiKeyDb process.exit

task 'populateWidgetTemplates', "Populates the database with widget templates", ->
  populateWidgetTemplates process.exit