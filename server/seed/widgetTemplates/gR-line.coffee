fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/gr-line"

name            = 'gR Line'
html            = ''
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js" 
json            = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl     = "/images/widgetTemplates/grLine.png"

module.exports  = {name, html, css, script, json, snapshotUrl}