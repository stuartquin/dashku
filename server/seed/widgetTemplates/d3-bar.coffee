fs          = require 'fs'
folderPath  = "#{__dirname}/../widgetTemplateFiles/d3-bar"

name        = "D3 Bar"
html        = ""
css         = fs.readFileSync "#{folderPath}/main.css"
script      = fs.readFileSync "#{folderPath}/main.js"
json        = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl = "/images/widgetTemplates/d3Bar.png"

module.exports = {name, html, css, script, json, snapshotUrl}