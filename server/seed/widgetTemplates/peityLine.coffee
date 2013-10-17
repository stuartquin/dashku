fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/peityLine"

name            = "Peity Line"
html            = fs.readFileSync "#{folderPath}/main.html"
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js"
json            = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl     = "/images/widgetTemplates/peityLine.png"

module.exports  = {name, html, css, script, json, snapshotUrl}