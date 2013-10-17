assert        = require 'assert'
Gently        = require 'gently'
ss            = require 'socketstream'

internals     = require "../../../server/internals"
config        = require "../../../server/config"

postman       = ss.api.app.helpers.postman
User          = ss.api.app.models.User
Dashboard     = ss.api.app.models.Dashboard
Redis         = ss.api.app.Redis

ass           = ss.start()


describe "Dashboard", ->

  describe "#create", ->

    describe "if the name and userId is present", ->

      it "should create the dashboard, and return a success status along with the dashboard", (done) ->
        # Assume that we are already logged in from authentication.coffee
        ass.rpc "dashboard.create", {name: "Nice dashboard"}, (res) ->
          assert.equal res[0].status, "success"
          assert.equal res[0].dashboard.name, "Nice dashboard"
          done()

      it "should emit a dashboardCreated event with the dashboard", (done) ->
        gently = new Gently
        User.findOne {}, (err, user) ->
          gently.expect ss.api.publish, 'channel', (channel, event, data) ->
            assert.equal channel, "user_#{user._id}"
            assert.equal event, "dashboardCreated"
            assert.equal data.name, "Yet another dashboard"
            done()
          ass.rpc "dashboard.create", {name: "Yet another dashboard"}, (res) ->
            assert.equal res[0].status, "success"
            ass.rpc "dashboard.delete", res[0].dashboard._id, (res) ->


    describe "if the name is not present", ->

      it "should return a failure status, and explain what went wrong", (done) ->
        ass.rpc "dashboard.create", {}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "Validation failed"
          done()


  describe "#getAll", ->

    it "should return a success status & the user's dashboards", (done) ->
      ass.rpc "dashboard.getAll", (res) ->
        assert.equal    res[0].status, "success"
        assert.notEqual res[0].dashboards, undefined
        assert.equal    res[0].dashboards[0].name, "Nice dashboard"
        assert.equal    res[0].dashboards[res[0].dashboards.length-1].name, "Your Dashboard"
        done()

  describe "#externalGet", ->

    describe "if dashboard is found", ->

      it "should subscribe the user to their own private channel"
      # TODO - find a way to observe channel creation

      it "should return a success status and the dashboard", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "dashboard.externalGet", dashboard._id, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].dashboard.name, dashboard.name
            assert.equal res[0].dashboard._id, dashboard._id.toString()             
            done()        

    describe "if dashboard is not found", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "dashboard.externalGet", "00001", (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "Dashboard not found"
          done()

  describe "#update", ->

    describe "if successful", ->

      it "should update the dashboard", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "dashboard.update", {_id: dashboard._id, name: "CheeseWin"}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].dashboard.name, "CheeseWin"
            Dashboard.findOne {_id: dashboard._id}, (err, dashboardReloaded) ->
              assert.equal dashboardReloaded.name, "CheeseWin"
              done()

      it "should emit a dashboardUpdated event to the user's channel, with the updated dashboard", (done) ->
        gently = new Gently
        User.findOne {}, (err, user) ->
          Dashboard.findOne {}, (err, dashboard) ->
            gently.expect ss.api.publish, 'channel', (channel, event, data) ->
              assert.equal channel, "user_#{user._id}"
              assert.equal event, "dashboardUpdated"
              assert.equal data.name, "CheeseWin 2.0"
              done()

            ass.rpc "dashboard.update", {_id: dashboard._id, name: "CheeseWin 2.0"}, (res) ->

    describe "if not successful, because the dashboard id does not exist", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "dashboard.update", {_id: "000111", name: "Bonobo"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "Dashboard not found"          
          done()

  describe "#delete", ->

    describe "if successful", ->

      it "should delete the dashboard, and return a success status along with the deleted dashboard's id", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "dashboard.delete", dashboard._id, (res) ->
            assert.equal "success", res[0].status
            assert.equal dashboard._id.toString(), res[0].dashboardId
            Dashboard.findOne {_id: dashboard._id}, (err, dashboardReloaded) ->
              assert.equal dashboardReloaded, null
              done()

      it "should emit a dashboardDeleted event to the user's channel, with the id of the deleted dashboard", (done) ->
        gently = new Gently
        User.findOne {}, (err, user) ->
          new Dashboard({userId: user._id, name: "Boom"}).save (err, dashboard) ->
            gently.expect ss.api.publish, 'channel', (channel, event, data) ->
              assert.equal channel, "user_#{user._id}"
              assert.equal "dashboardDeleted", event
              assert.equal data, dashboard._id.toString()
              done()
            ass.rpc "dashboard.delete", dashboard._id, (res) ->


    describe "if not successful because only one dashboard remains", ->

      it "should return a failure status and explain what went wrong", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "dashboard.delete", dashboard._id, (res) ->
            assert.equal "failure", res[0].status
            assert.equal "You can't delete your last dashboard", res[0].reason
            done()

    describe "if not successful because dashboard id does not exist", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "dashboard.create", {name: "YA Dashboard"}, (err, dashboard) ->
          ass.rpc "dashboard.delete", "00001", (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "Dashboard not found"
            done()

  describe "#updateWidgetPositions", ->

    describe "if successful", ->
      
      it "should set the widget's position to the new value", (done) ->
        ass.rpc "dashboard.create", {name: "Sales Dashboard"}, (res) ->
          dashboard = res[0].dashboard
          ass.rpc "widget.create", {dashboardId: dashboard._id, name: "Widget 1"}, (res) ->
            widget1 = res[0].widget
            ass.rpc "widget.create", {dashboardId: dashboard._id, name: "Widget 2"}, (res) ->
              widget2 = res[0].widget
              ass.rpc "widget.create", {dashboardId: dashboard._id, name: "Widget 3"}, (res) ->
                widget3 = res[0].widget
                positions = {}
                positions[widget1._id] = 1
                positions[widget2._id] = 2
                positions[widget3._id] = 0                
                ass.rpc "dashboard.updateWidgetPositions", {_id: dashboard._id, positions: positions}, (res) ->
                  assert.equal res[0].status, "success"
                  Dashboard.findOne {_id: dashboard._id}, (err, dashboardReloaded) ->
                    assert.equal dashboardReloaded.widgets[0].position, 1
                    assert.equal dashboardReloaded.widgets[1].position, 2
                    assert.equal dashboardReloaded.widgets[2].position, 0
                    done()

      it "should emit a widgetPositionsUpdated event to the user's channel, with the positions data", (done) ->
        gently = new Gently
        Dashboard.findOne {name: "Sales Dashboard"}, (err, dashboard) ->
          positions = {}
          positions[dashboard.widgets[0]._id] = 0
          positions[dashboard.widgets[1]._id] = 1
          positions[dashboard.widgets[2]._id] = 2
          gently.expect ss.api.publish, 'channel', (channel, event, data) ->
            assert.equal channel, "user_#{dashboard.userId}"
            assert.equal event, "widgetPositionsUpdated"
            assert.equal data._id, dashboard._id.toString()
            assert.equal data.positions[dashboard.widgets[0]._id], 0
            assert.equal data.positions[dashboard.widgets[1]._id], 1
            assert.equal data.positions[dashboard.widgets[2]._id], 2
            done()
          ass.rpc "dashboard.updateWidgetPositions", {_id: dashboard._id, positions: positions}, (res) ->
  

    describe "if not successful, because the dashboard does not exist", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "dashboard.updateWidgetPositions", {_id: "00001111", positions: {}}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "Dashboard not found"
          done()