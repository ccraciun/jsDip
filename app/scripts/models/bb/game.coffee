backbone = require 'backbone'

Models = {
  GameDefinition: require './game_definition'
  State: require './state'
  GameDate: require './game_date'
}
Collections = {
  Provinces: require '../../collections/provinces'
}

module.exports = class Game extends backbone.Model
  parse: (data, options) ->
    {
      gameDefinition: new Models.GameDefinition(data.gameDefinition, parse: true)
      state: new Models.State(data.state, parse: true)
      provinces: new Collections.Provinces(data.provinces,
        coords: data.coords
        parse: true)
    }
