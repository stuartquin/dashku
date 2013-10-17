ss        = require "socketstream"
assert    = require "assert"
internals = require "../../../server/internals" 

User = ss.api.app.models.User

describe "User", ->

  describe "new", ->

    before (done) ->
      User.remove {}, (err) ->
        done()

    it "should encrypt the password", (done) ->
      userCredentials = 
        username: "paulbjensen"
        email:    "paul@anephenix.com"
        password: "123456"

      new User(userCredentials).save (err, doc) ->
        assert.equal doc.password         , undefined
        assert.notEqual doc.passwordHash  , undefined
        assert.notEqual doc.passwordSalt  , undefined
        done()

  describe "validations", ->

    describe "username", ->

      beforeEach (done) ->
        User.remove {}, (err) ->
          userCredentials = 
            username: "paulbjensen"
            email:    "paul@anephenix.com"
            password: "123456"
          new User(userCredentials).save (err, doc) ->
            assert.equal err, null
            done()      

      it "should be unique", (done) ->
          userCredentials = 
            username: "paulbjensen"
            email:    "bob@bob.com"
            password: "123456"

          new User(userCredentials).save (err, doc) ->
            assert.notEqual err, null
            User.count (err, count) ->
              assert.equal count, 1
              done()

      it "should be present", (done) ->
        userCredentials = 
          email: "ren@renandstimpy.com"
          password: "123456"

        new User(userCredentials).save (err, doc) ->
          assert.notEqual err, null
          done()

    describe "email", ->

      beforeEach (done) ->
        User.remove {}, (err) ->
          username  = "paulbjensen"
          email     = "paul@anephenix.com"
          password  = "123456"
          user = new User {username, email, password}
          user.save (err, doc) ->
            done()

      it "should be unique", (done) ->

        userCredentials = 
          username: "paul"
          email:    "paul@anephenix.com"
          password: "123456"

        new User(userCredentials).save (err, doc) ->
          assert.notEqual err, null
          User.count (err, count) ->
            assert.equal count, 1
            done()

      it "should be present", (done) ->
        userCredentials = 
          username: "ren"
          password: "123456"

        new User(userCredentials).save (err, doc) ->
          assert.notEqual err, null
          done()

    describe "password", ->

      it "should be present", (done) ->

        userCredentials = 
          username: "ren"
          email: "ren@renandstimpy.com"

        new User(userCredentials).save (err, doc) ->
          assert.notEqual err, null
          done()