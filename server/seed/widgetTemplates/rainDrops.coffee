fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/rainDrops"

name            = "D3 Raindrops"
html            = ""
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js"
json            = '{}'
snapshotUrl     = "/images/widgetTemplates/rainDrops.png"

module.exports  = {name, html, css, script, json, snapshotUrl}