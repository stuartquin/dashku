module.exports = ->

  @World = require("../support/world.coffee").World

  @Given /^a user has created an account$/, (callback) ->
    callback.pending()

  @Given /^they have logged in$/, (callback) ->
    callback.pending()

  @When /^they click on the "([^"]*)" button$/, (arg1, callback) ->
    callback.pending()

  @Then /^they should see the "([^"]*)" modal$/, (arg1, callback) ->
    callback.pending()

  @When /^they fill in "([^"]*)" with "([^"]*)"$/, (arg1, arg2, callback) ->
    callback.pending()

  @When /^they press "([^"]*)"$/, (arg1, callback) ->
    callback.pending()

  @Then /^they should see "([^"]*)"$/, (arg1, callback) ->
    callback.pending()

# /Users/paulbjensen/Work/anephenix/dashku/features/dashboards.feature:63 # Scenario: Delete the Dashboard
# /Users/paulbjensen/Work/anephenix/dashku/features/delete_user_account.feature:6 # Scenario: Delete my account
# /Users/paulbjensen/Work/anephenix/dashku/features/login.feature:6 # Scenario: Login (with username)
# /Users/paulbjensen/Work/anephenix/dashku/features/login.feature:30 # Scenario: Fail to login (incorrect username/email)
# /Users/paulbjensen/Work/anephenix/dashku/features/login.feature:43 # Scenario: Fail to login (incorrect password)
# /Users/paulbjensen/Work/anephenix/dashku/features/widgets.feature:123 # Scenario: Modify a Widget's JavaScript
# /Users/paulbjensen/Work/anephenix/dashku/features/widgets.feature:186 # Scenario: Switch between JavaScript and CoffeeScript