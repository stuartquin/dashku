fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/peityChart"

name            = "Peity Chart"
html            = ""
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js"
json            = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl     = "/images/widgetTemplates/peityChart.png"

module.exports  = {name, html, css, script, json, snapshotUrl}