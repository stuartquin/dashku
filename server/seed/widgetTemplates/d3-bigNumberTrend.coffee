fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/d3-bigNumberTrend"

name            = 'D3 Trend'
json            = fs.readFileSync "#{folderPath}/main.json"
script          = fs.readFileSync "#{folderPath}/main.js"
css             = fs.readFileSync "#{folderPath}/main.css"
html            = ''
snapshotUrl     = "/images/widgetTemplates/d3-bigNumberTrend.png"

module.exports  = {name, json, script, css, html, snapshotUrl}
