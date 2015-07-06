_ = require 'underscore'
backbone = require 'backbone'

Views = {
  Map: require './views/bb/map'
  Header: require './views/bb/header'
}
Models = {
  GameDefinition: require './models/bb/game_definition'
  Map: require './models/bb/map'
  Game: require './models/bb/game'
}
Collections = {
  Provinces: require './collections/provinces'
}
Data = {
  Base: {
    gameDefinition: require '../data/game_definition.json'
    state: require '../data/start_state.json'
    provinces: require '../data/provinces.json'
    coords: require '../data/coords.json'
  }
}

module.exports = class DiplomacyGame extends backbone.View
  initialize: ->
    @subViews = {
      map: new Views.Map("images/europe_standard.svg")
      header: new Views.Header()
    }
    @model = new Models.Game(Data.Base, parse: true)

  render: ->
    @renderSubViews()

  renderSubViews: ->
    for view in _(@subViews).values()
      view.render()
