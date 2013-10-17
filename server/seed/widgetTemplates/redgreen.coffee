fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/redgreen"

name            = 'Red Green'
json            = '{}'
script          = fs.readFileSync "#{folderPath}/main.js"
css             = ''
html            = ''
snapshotUrl     = "/images/widgetTemplates/redgreen.png"

module.exports  = {name, html, css, script, json, snapshotUrl}