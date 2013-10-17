fs              = require 'fs'
folderPath      = "#{__dirname}/../widgetTemplateFiles/d3-bullet"

name            = "D3 Bullet"
html            = fs.readFileSync "#{folderPath}/main.html"
css             = fs.readFileSync "#{folderPath}/main.css"
script          = fs.readFileSync "#{folderPath}/main.js" 
json            = fs.readFileSync "#{folderPath}/main.json"
snapshotUrl     = "/images/widgetTemplates/d3BulletImg.png"

module.exports  = {name, html, css, script, json, snapshotUrl}
