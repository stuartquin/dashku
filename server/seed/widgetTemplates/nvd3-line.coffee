fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/nvd3-line"

name            = 'NVD3 line'
json            = fs.readFileSync "#{folderPath}/main.json"
script          = fs.readFileSync "#{folderPath}/main.js"
css             = fs.readFileSync "#{folderPath}/main.css"
html            = ''
snapshotUrl     = "/images/widgetTemplates/nvd3line.png"

module.exports  = {name, json, script, css, html, snapshotUrl}
