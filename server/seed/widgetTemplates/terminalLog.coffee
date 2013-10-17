fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/terminalLog"

name            = 'Terminal Log'
json            = fs.readFileSync "#{folderPath}/main.json"
script          = fs.readFileSync "#{folderPath}/main.js"
scriptType      = "coffeescript"
css             = fs.readFileSync "#{folderPath}/main.css"
html            = ''
snapshotUrl     = "/images/widgetTemplates/terminalLog.png"

module.exports  = {name, html, css, script, json, snapshotUrl}