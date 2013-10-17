#### Widget Template RPC module ####

ss             = require 'socketstream'
WidgetTemplate = ss.api.app.models.WidgetTemplate

exports.actions = (req, res, ss) ->

  getAll: ->
    WidgetTemplate.find {}, (err, docs) ->
      if !err
        res status: 'success', widgetTemplates: docs
      else
        res status: 'failure', reason: err