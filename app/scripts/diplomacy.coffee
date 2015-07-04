_ = require 'underscore'
Views = {
  Map: require './views/bb/map'
  Header: require './views/bb/header'
}
Models = {
  GameDefinition: require './models/bb/game_definition'
  Map: require './models/bb/map'
}
Collections = {
  Provinces: require './collections/provinces'
}
Data = {
  Base: {
    GameDefinition: require '../data/game_definition.json'
    StartState: require '../data/start_state.json'
    Provinces: require '../data/provinces.json'
  }
  # If we want to include variations, here's how. Any files provided below
  # should be used to override the Base data for the particular variation.
  #
  # Variations: {
  #   ScOnlyStart: {
  #     StartState: require '../data/Variations/sconly_start/start_state.json'
  #   }
  # }
}

module.exports = class DiplomacyGame
  constructor: ->
    @views = {
      map: new Views.Map("images/europe_standard.svg")
      header: new Views.Header()
    }
    @models = {
      gameDefinition: new Models.GameDefinition(Data.Base.GameDefinition, parse: true)
      provinces: new Collections.Provinces(Data.Base.Provinces, parse: true)
      # state: new Models.State(Data.Base.StartState, parse: true)
    }

  init: ->
    @renderViews()

  renderViews: ->
    for view in _(@views).values()
      view.render()
