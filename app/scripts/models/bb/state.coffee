backbone = require 'backbone'
_ = require 'underscore'
Models = {
  GameDate: require './game_date'
}
Collections = {
  Forces: require '../../collections/forces'
}

module.exports = class State extends backbone.Model
  parse: (data, options) ->
    _(super).tap (attrs) ->
      attrs.date = new Models.GameDate(attrs.date, parse: true)
      attrs.forces = new Collections.Forces(attrs.forces, parse: true)
