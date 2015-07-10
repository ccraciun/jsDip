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
    provinces = new Collections.Provinces(
      data.provinces,
      coords: data.coords
      parse: true
    )
    {
      gameDefinition: new Models.GameDefinition(data.gameDefinition, parse: true)
      state: new Models.State(data.state, provinces: provinces, parse: true)
      provinces: provinces
    }
