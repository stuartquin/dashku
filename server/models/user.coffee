#### User model ####
bcrypt     = require 'bcrypt'
uuid       = require 'node-uuid'
mongoose   = require 'mongoose'

hashPassword = (password, cb) ->
  bcrypt.genSalt 10, (err, salt) -> 
    bcrypt.hash password, salt, (err, hash) -> 
      cb {hash, salt}

# NOTE - the password attribute exists in order
# to have a way to pass the value to the 
# encryption method. It is wiped clean by the 
# encryption method afterwards.
#
# This is a workaround for the moment, until I
# figure out a better way.
#

module.exports = (app) ->

  app.schemas.Users = new mongoose.Schema
    username            : type: String, lowercase: true, required: true, index: {unique: true, dropDups: false}
    email               : type: String, lowercase: true, required: true, index: {unique: true, dropDups: false}
    password            : String                          
    passwordHash        : String
    passwordSalt        : String
    createdAt           : type: Date,   default: Date.now
    updatedAt           : type: Date,   default: Date.now
    apiKey              : type: String, default: uuid.v4
    changePasswordToken : String

  # Clean the password attribute
  app.schemas.Users.pre 'save', (next) ->
    if @isNew
      if @password is undefined
        next new Error "Password field is missing"
      else
        hashPassword @password, (hashedPassword) =>
          @passwordHash = hashedPassword.hash
          @passwordSalt = hashedPassword.salt
          @password     = undefined
          next()
    else
      next()

  app.models.User = mongoose.model 'User', app.schemas.Users
