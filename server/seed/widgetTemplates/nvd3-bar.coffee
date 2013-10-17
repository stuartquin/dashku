fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/nvd3-bar"

name            = 'NVD3 bar'
json            = fs.readFileSync "#{folderPath}/main.json"
script          = fs.readFileSync "#{folderPath}/main.js"
css             = fs.readFileSync "#{folderPath}/main.css"
html            = ''
snapshotUrl     = "/images/widgetTemplates/nvd3Bar.png"

module.exports  = {name, json, script, css, html, snapshotUrl}