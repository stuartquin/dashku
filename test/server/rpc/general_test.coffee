assert        = require 'assert'
md            = require 'marked'
fs            = require 'fs'
ss            = require 'socketstream'

internals     = require "../../../server/internals"
config        = require '../../../server/config'

User          = ss.api.app.models.User
ass           = ss.start()

describe "General", ->

  describe "#getDocument", ->

    describe "if successful", ->
 
      it "should return a content object containing rendered markdown", (done) ->
        file = "introduction/index"
        fs.readFile "#{__dirname}/../../../server/docs/#{file}.md", 'utf8', (err, data) ->
          ass.rpc 'general.getDocument', file, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].content, md data
            done()

      it "should replace references to API_KEY with the user's api key", (done) ->
        # We assume that we are logged in as the first user
        User.findOne {}, (err, user) ->
          file = "api/transmit"
          ass.rpc 'general.getDocument', file, (res) ->
            assert.equal res[0].status, "success"
            assert res[0].content.match(user.apiKey) isnt null
            done()

      it "should replace references to DASHKU_API_URL with the api url for Dashku", (done) ->
        # We assume that we are logged in as the first user
        User.findOne {}, (err, user) ->
          file = "api/transmit"
          ass.rpc 'general.getDocument', file, (res) ->
            assert.equal res[0].status, "success"
            assert res[0].content.match(config[ss.env].apiHost) isnt null
            done()

    describe "if not successful", ->

      it "should return a string saying 'Error accessing document'", (done) ->
        ass.rpc "general.getDocument", 'waa/waaa', (res) ->
          assert.equal res[0].content, "Document not found"
          done()
