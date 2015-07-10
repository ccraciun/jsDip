backbone = require('backbone')

module.exports = class GameDefinition extends backbone.Model
  # not quite sure if this whole class is even needed.
  # right now, it just defines the order of seasons...
  initialize: ->
    super
