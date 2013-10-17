#### General RPC module ####

md                    = require 'marked'
fs                    = require 'fs'
ss                    = require 'socketstream'
_                     = require 'underscore'
fetchUserFromSession  = ss.api.app.helpers.fetchUserFromSession
config                = ss.api.app.config

docData = {}

renderDocument = (id, data, req, res) ->
  if id.match("api/")?
    fetchUserFromSession req, res, (user) ->
      data = data.replace /API_KEY/g , user.apiKey
      data = data.replace /DASHKU_API_URL/g , config.apiHost
      res status: "success", content: md data
  else
    res status: "success", content: md data

exports.actions = (req, res, ss) ->  

  req.use 'session'

  # This fetches a markdown document from the documentation, and returns the rendered html
  getDocument: (id) ->
    if docData[id]?
      data = docData[id]
      renderDocument id, data, req, res
    else
      fs.readFile "#{__dirname}/../docs/#{id}.md", 'utf8', (err, data) ->
        if !err
          docData[id] = data
          renderDocument id, data, req, res
        else
          res status: "failure", content: "Document not found"