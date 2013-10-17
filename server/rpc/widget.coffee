#### Widget RPC module ####

ss                    = require "socketstream"
widgetController      = ss.api.app.controllers.widget
fetchUserFromSession  = ss.api.app.helpers.fetchUserFromSession

exports.actions = (req, res, ss) ->

  req.use 'session'

  create: (data) ->
    fetchUserFromSession req, res, (user) ->
      widgetController.create data, user, (response) -> res response

  update: (data) ->
    fetchUserFromSession req, res, (user) ->
      widgetController.update data, (response) -> res response

  delete: (data) ->
    fetchUserFromSession req, res, (user) ->
      widgetController.delete data, (response) -> res response