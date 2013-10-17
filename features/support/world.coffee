selenium              = require 'selenium-launcher'
soda                  = require 'soda'
process.env["SS_ENV"] = "cucumber"
ss                    = require 'socketstream'
config                = require '../../server/config.coffee'
app                   = require '../../app.coffee'

browser = null

World = (callback) ->

    @wrap = (funk, cb) ->
      funk.end (err) ->        
        if err? then cb.fail err else cb()

    @shouldBeOnThePage = (browser, callback, selector) ->
      @wrap browser.chain.waitForElementPresent(selector), callback
  
    if browser is null
      selenium (err, selenium) =>
        process.on 'exit', -> selenium.kill()
 
        browser = soda.createClient
          host:     selenium.host
          port:     selenium.port
          url:      config[ss.env].apiHost
          browser:  "firefox"

        @browser  = browser
        callback {@browser, @wrap, @shouldBeOnThePage}
    else
      @browser  = browser
      callback {@browser, @wrap, @shouldBeOnThePage}

exports.World = World