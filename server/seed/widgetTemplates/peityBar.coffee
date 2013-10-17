fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/peityBar"

name            = "Peity Bar"
html            = fs.readFileSync "#{folderPath}/main.html"
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js"
json            = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl     = "/images/widgetTemplates/peityBar.png"

module.exports  = {name, html, css, script, json, snapshotUrl}