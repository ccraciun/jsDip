_ = require 'underscore'
backbone = require 'backbone'

Views = {
  Base: require './base'
  Map: require './map'
  Header: require './header'
}
Models = {
  GameDefinition: require '../../models/bb/game_definition'
  Map: require '../../models/bb/map'
  Game: require '../../models/bb/game'
}
Collections = {
  Provinces: require '../../collections/provinces'
}
Data = {
  Base: {
    gameDefinition: require '../../../data/game_definition.json'
    state: require '../../../data/start_state.json'
    provinces: require '../../../data/provinces.json'
    coords: require '../../../data/coords.json'
  }
}

module.exports = class DiplomacyGame extends Views.Base
  initialize: ->
    @model = new Models.Game(Data.Base, parse: true)
    @subViews = {
      map: new Views.Map(svgUrl: "images/europe_standard.svg", model: @model)
      header: new Views.Header(model: @model.get('state'))
    }

  render: ->
    @renderSubViews()

  renderSubViews: ->
    for view in _(@subViews).values()
      view.render()
