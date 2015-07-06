backbone = require 'backbone'
Models = {
  GameDate: require './game_date'
}
Collections = {
  Forces: require '../../collections/forces'
}

module.exports = class State extends backbone.Model
  initialize: (attrs, options) ->
    super

  parse: (data, options) ->
    return
    attrs = super(data.state, options)
    attrs.defs = data.defs
    attrs.date = new Models.GameDate(attrs.date, parse: true)
    attrs.forces = new Collections.Forces(attrs.forces, parse: true)
