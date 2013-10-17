# TODO - once #299 on SocketStream is resolved,
# go through all of the tests, and implement
# logout as an after() cleanup where appropriate

assert        = require "assert"
Gently        = require "gently"
uuid          = require 'node-uuid'
ss            = require "socketstream"
internals     = require "../../../server/internals"
config        = require "../../../server/config"

postman       = ss.api.app.helpers.postman
User          = ss.api.app.models.User
Dashboard     = ss.api.app.models.Dashboard
Redis         = ss.api.app.Redis

ass           = ss.start()

describe "Authentication", ->
  
  before (done) ->
    User.remove {}, (err) =>
      Dashboard.remove {}, (err) =>
        done()

  describe "#signup", ->

    describe "if a valid request is made", ->

      before (done) ->

        @res = null

        newUserCredentials = 
          username: "paul"
          email:    "paul@anephenix.com" 
          password: "123456"

        ass.rpc 'authentication.signup', newUserCredentials, (res) =>
          # For some reason, the res object called back is an array,
          # rather than the object that we get back in the browser
          #
          # See https://github.com/socketstream/socketstream/issues/278
          # for more information on this bug.
          #
          @res = res[0]
          done()

      it "should create a new user record", (done) ->
          User.count (err,count) ->
            assert.equal 1, count
            done()

      it "should append a new hash to the apiKeys set in Redis", (done) ->
        User.findOne {_id: @res.user._id}, (err, user) ->
          Redis.hget "apiKeys", user.apiKey, (err,val) ->
            assert.equal val, user._id
            done()

      it "should generate a dashboard for the new user", (done) ->
        Dashboard.findOne {userId: @res.user._id}, (err, dashboard) ->
          assert.equal dashboard.name, "Your Dashboard"
          done()

      it "should subscribe the user to their own private channel"
      # It would be nice if we could observe channels being 
      # created via pubsub. Find out how.

      it "should return a success response", (done) ->
        assert.equal @res.status, "success"
        done()

    describe "if the user already exists", ->

      before (done) ->

        @res = null 

        newUserCredentials = 
          username: "paul" 
          email:    "paul@anephenix.com" 
          password: "123456"

        ass.rpc 'authentication.signup', newUserCredentials, (res) =>
          @res = res[0]
          done()

      it "should not create another user", (done) ->
        User.count (err,count) ->
          assert.equal 1, count
          done()

      it "should return a failure response", (done) ->
        assert.equal @res.status, "failure"
        done()

    describe "if the user is missing some credentials", ->


      it "should return a failure response", (done) ->

        missingUsername = 
          email:    "earthworm@jim.com"
          password: "123456"

        missingEmail = 
          username: "earthwormJim"
          password: "123456"

        missingPassword = 
          username: "earthwormJim0"
          email:    "earthworm0@jim.com"

        ass.rpc 'authentication.signup', missingUsername, (res) ->
          assert.equal res[0].status, "failure"

          ass.rpc 'authentication.signup', missingEmail, (res) ->
            assert.equal res[0].status, "failure"

            ass.rpc 'authentication.signup', missingPassword, (res) ->
              assert.equal res[0].status, "failure"
              done()

  describe "#signedIn", ->

    it "should return the currently signed-in user", (done) ->
      User.findOne {username: "paul"}, (err, user) ->
        ass.rpc "authentication.login", {identifier: "paul", password: "123456"}, (r) ->
          ass.rpc "authentication.signedIn", {identifier: "paul", password: "123456"}, (res) ->
            assert.equal res[0].user.username, user.username
            assert.equal res[0].user.email, user.email
            assert.equal res[0].user._id, user._id.toString()
            assert.equal res[0].status, "success"
            done()

    it "should subscribe the user to their own private channel"

  describe "#login", ->

    describe "if successful", ->

      it "should return a success status, and the user object", (done) ->
       User.findOne {username: "paul"}, (err, user) ->
          ass.rpc "authentication.login", {identifier: "paul", password: "123456"}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].user.username, user.username
            assert.equal res[0].user.email, user.email
            assert.equal res[0].user._id, user._id.toString()
            done()

      it "should subcribe the user to their private channel"

    describe "if not successful, because the password is not correct", ->

      it "should return the failure status, and explain what went wrong", (done) ->
        ass.rpc "authentication.login", {identifier: "paul", password: "waaaaaaaa"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "password incorrect"
          done()

    describe "if not successful, because the user doesn't exist", ->

      it "should return the failure status, and explain what went wrong", (done) ->
          ass.rpc "authentication.login", {identifier: "bambam", password: "waaaaaaaa"}, (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "the user bambam does not exist"
            done()


  # The test here is causing ss to raise an error when clearing session channels.
  describe "#logout", ->

    #it "should remove the userId attribute from the session"

    #it "should clear all channels that the session was subscribed to"

    it "should return a success status", (done) ->
      ass.rpc "authentication.login", {identifier: "paul", password: "123456"}, (r) ->
        assert.equal r[0].status, "success"
        ass.rpc "authentication.logout", (res) ->
          assert.equal res[0].status, "success"
          done()
      # TODO - figure out what should happen if you call the signedIn method 
      # after you have signed out.

  describe "#isAttributeUnique", ->

    it "should return true if the query finds a document that matches the criteria", (done) ->
      ass.rpc "authentication.isAttributeUnique", {username: "waa"}, (res) ->
        assert.equal res[0], true
        done()

    it "should return false if the query does not find a document that matches the criteria", (done) ->
      ass.rpc "authentication.isAttributeUnique", {username: "paul"}, (res) ->
        assert.equal res[0], false
        done()

  describe "#account", ->

    it "should return the user object based on the user's session, including their api usage", (done) ->
      User.findOne {username: "paul"}, (err, user) ->
        ass.rpc "authentication.login", {identifier: "paul", password: "123456"}, (r) ->
          ass.rpc "authentication.account", (res) ->
            assert.equal res[0].user._id, user._id.toString()
            assert.equal res[0].user.username, user.username
            assert.equal res[0].user.email, user.email
            assert.equal res[0].user.apiUsage, 0
            assert.equal res[0].status, "success"
            done()

  describe "#forgotPassword", ->

    describe "if a user is found", ->

      it "should generate a change password token for the user", (done) ->
        identifier = "paul"
        User.findOne {username: identifier}, (err, user) ->
          assert.equal user.changePasswordToken, undefined
          ass.rpc "authentication.forgotPassword", identifier, (res) ->
            assert.equal res[0].status, "success"
            User.findOne {username: identifier}, (err, userReloaded) ->
              assert.notEqual userReloaded.changePasswordToken, undefined
              done()

      it "should send an email to the user with a link to follow to change their password", (done) ->
        gently      = new Gently
        identifier  = "paul"
        gently.expect postman, 'sendMail', (sm) ->
          fpToken = sm.text.split('fptoken=')[1].split(/\n/)[0]
          assert.equal sm.from, "Dashku Admin <admin@dashku.com>"
          assert.equal sm.to, "paul@anephenix.com"
          assert.equal sm.subject, "Forgotten Password"
          assert.equal sm.text, "Hi,\n\nWe got a notification that you\'ve forgotten your password. It\'s cool, we\'ll help you out. \n\nIf you wish to change your password, follow this link: #{config[ss.env].apiHost}?fptoken=#{fpToken}\n\nRegards,\n\n  Dashku Admin"
          assert.equal sm.html, "<p>Hi,</p>\n<p>We got a notification that you\'ve forgotten your password. It\'s cool, we\'ll help you out.</p>\n<p>If you wish to change your password, follow this link: <a>#{config[ss.env].apiHost}?fptoken=#{fpToken}</a></p>\n<p>Regards,</p>\n<p>  Dashku Admin</p>"
          done()
        ass.rpc "authentication.forgotPassword", identifier, (res) ->


    describe "if a user is not found", ->

      it "should return a failure status and explain what went wrong", (done) ->
        identifier = "theVanBowserBomb"
        ass.rpc "authentication.forgotPassword", identifier, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "User not found with identifier: #{identifier}"
          done()

  describe "#loadChangePassword", ->

    describe "if the token is valid", ->

      it "should return a success status", (done) ->
        newToken = uuid.v4()
        User.findOne {username: "paul"}, (err, user) ->
          user.changePasswordToken = newToken
          user.save (err) ->
            ass.rpc "authentication.loadChangePassword", newToken, (res) ->
              assert.equal res[0].status, "success"
              done()

    describe "if the token is not valid", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "authentication.loadChangePassword", "waa", (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "No user found with that token"
          done()

  describe "#changePassword", ->

    describe "if the user's token is valid", ->

      describe "if a password is provided", ->

        it "should change the user's password to the password provided, change the token, and return a success status", (done) ->
          newToken = uuid.v4()
          User.findOne {username: "paul"}, (err, user) ->
            user.changePasswordToken = newToken
            user.save (err) ->
              ass.rpc "authentication.changePassword", {token: newToken, password: "poiuyt"}, (res) ->
                assert.equal res[0].status, "success"
                ass.rpc "authentication.login", {identifier: "paul", password: "poiuyt"}, (res) ->
                  assert.equal res[0].status, "success"
                  User.findOne {username: "paul"}, (err, user) ->
                    assert.notEqual user.changePasswordToken, newToken
                    done() 

      describe "if a password is not provided", ->

        it "should return a failure status and explain what went wrong", (done) ->
          newToken = uuid.v4()
          User.findOne {username: "paul"}, (err, user) ->
            user.changePasswordToken = newToken
            user.save (err) ->
              ass.rpc "authentication.changePassword", {token: newToken}, (res) ->
                assert.equal res[0].status, "failure"
                assert.equal res[0].reason, "new password was not supplied"
                done()

    describe " if the user's token is not valid", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "authentication.changePassword", {token: "waa"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "No user found with that token"
          done()

  describe "#changeAccountPassword", ->

    describe "if the user's password matches", ->

      describe "if a new password is provided", ->

        it "should change the user's password to the password provided", (done) ->
          # We're already logged in as username: paul
          ass.rpc "authentication.changeAccountPassword", {currentPassword: "poiuyt", newPassword: "qwerty"}, (res) ->
            assert.equal res[0].status, "success"
            ass.rpc "authentication.login", {identifier: "paul", password: "qwerty"}, (res) ->
              assert.equal res[0].status, "success"
              done()

      describe "if a new password is not provided", ->

        it "should return a failure status and explain what went wrong", (done) ->
          ass.rpc "authentication.changeAccountPassword", {currentPassword: "qwerty"}, (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "new password was not supplied"
            done()

    describe "if the user's password does not match", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "authentication.changeAccountPassword", {currentPassword: "cheeseWin", newPassword: "qwerty"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "Current password supplied was invalid"
          done()

  describe "#changeEmail", ->

    describe "if an email address is provided", ->
      
      describe "if the email address is unique", ->

        it "should change the user's email address, and return a success status", (done) ->
          User.findOne {username: "paul"}, (err, user) ->
            ass.rpc "authentication.login", {identifier: "paul@anephenix.com", password: "qwerty"}, (res) ->
              assert.equal res[0].status, "success"
              ass.rpc "authentication.changeEmail", {email: "paulbjensen@gmail.com"}, (res) ->
                User.findOne {_id: user._id}, (err, userReloaded) ->
                  assert.equal res[0].status, "success"
                  assert.equal userReloaded.email, "paulbjensen@gmail.com"
                  done()

      describe "if the email address is not unique", ->

        it "should return a failure status and explain what went wrong", (done) ->
          new User({username: "johny_bravo", email:"johny@bravo.com", password: "123456"}).save (err, dupUser) ->
            ass.rpc "authentication.login", {identifier: "paulbjensen@gmail.com", password: "qwerty"}, (res) ->
              assert.equal res[0].status, "success"
              ass.rpc "authentication.changeEmail", {email: "johny@bravo.com"}, (res) ->
                assert.equal res[0].status, "failure"
                assert.equal res[0].reason, "Someone already has that email address."
                done()

    describe "if an email address is not provided", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "authentication.login", {identifier: "paulbjensen@gmail.com", password: "qwerty"}, (res) ->
          assert.equal res[0].status, "success"
          ass.rpc "authentication.changeEmail", {}, (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "Validation failed"
            done()