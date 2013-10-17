ss                    = require 'socketstream'
Dashboard             = ss.api.app.models.Dashboard
apiUrl                = ss.api.app.config.apiUrl

rubyScript = '### Instructions
\n#    gem install em-http-request
\n#    ruby dashku_WIDGETID.rb
\n#
\nrequire "rubygems"
\nrequire "json"
\nrequire "em-http-request"
\n
\ndata = JSON.parse(\'JSONDATA\')
\n
\nEventMachine.run {
\n  http = EventMachine::HttpRequest.new("URL").post :body => data
\n  http.callback {
\n    EventMachine.stop
\n  }
\n}'

nodejsScript = '// Instructions
\n//    npm install request
\n//    node dashku_WIDGETID.js
\n//
\nvar request = require("request");
\n
\nvar data = JSONDATA;
\n
\nrequest.post({url: "URL", body: data, json: true});'


coffeeScript = '# Instructions
\n#    npm install request
\n#    coffee dashku_WIDGETID.coffee
\n#
\nrequest = require "request"
\n
\ndata = JSONDATA;
\n
\nrequest.post url: "URL", body: data, json: true'

phpScript = '<?
\n// Instructions
\n// 
\n// php dashku_WIDGETID.php
\n//
\n// This code is courtesy of 
\n// Dan Morgan
\n//
\n// http://www.danmorgan.net/programming/simple-php-json-rest-post-client/
\n// 
\nfunction restcall($url,$vars) {
\n $headers = array(
\n \'Accept: application/json\',
\n \'Content-Type: application/json\',
\n );
\n $data = $vars;
\n 
\n $handle = curl_init();
\n curl_setopt($handle, CURLOPT_URL, $url);
\n curl_setopt($handle, CURLOPT_HTTPHEADER, $headers);
\n curl_setopt($handle, CURLOPT_RETURNTRANSFER, true);
\n curl_setopt($handle, CURLOPT_SSL_VERIFYHOST, false);
\n curl_setopt($handle, CURLOPT_SSL_VERIFYPEER, false);
\n 
\n curl_setopt($handle, CURLOPT_POST, true);
\n curl_setopt($handle, CURLOPT_POSTFIELDS, $data);
\n 
\n $response = curl_exec($handle);
\n $code = curl_getinfo($handle, CURLINFO_HTTP_CODE);
\n return $response;
\n}
\n
\nrestcall("THEURL",\'JSONDATA\');
\n?>'

pythonScript = '# Instructions
\n#
\n# easy_install requests
\n# python dashku_WIDGETID.py
\n#
\nimport requests
\nimport json
\n
\npayload = JSONDATA
\nheaders = {\'content-type\': \'application/json\'}
\n
\nrequests.post(\'URL\', data=json.dumps(payload),headers=headers)'

attributes = 
  rb:
    script       : rubyScript
    contentType  : 'ruby'
  js:
    script       : nodejsScript
    contentType  : 'javascript'
  coffee:
    script       : coffeeScript
    contentType  : 'coffeescript'
  php:
    script       : phpScript
    contentType  : 'php'
  py:
    script       : pythonScript
    contentType  : 'python'    

wrapperFunction = (req,res, fileFormat) ->
  Dashboard.findOne {_id: req.params.dashboardId}, (err, dashboard) ->
    if !err and dashboard?
      widget = dashboard.widgets.id(req.params.id)
      data = attributes[fileFormat].script.replace(/URL/,apiUrl).replace(/JSONDATA/,widget.json).replace(/WIDGETID/,widget._id)
      res.writeHead 200, { 'Content-disposition': 'attachment', 'Content-Type': "application/#{attributes[fileFormat].contentType}" }
      res.end data
    else
      res.writeHead 402, { 'Content-Type': 'text/plain' }
      res.end err

module.exports = (req,res) ->
  parsedFormat = req.params.format.split '.'
  fileFormat   = parsedFormat[parsedFormat.length-1]

  if attributes[fileFormat] is undefined
    res.writeHead 402, { 'Content-Type': 'text/plain' }
    res.end "not identified"
  else
    wrapperFunction req, res, fileFormat