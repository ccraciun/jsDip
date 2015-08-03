_ = require 'underscore'
backbone = require 'backbone'
Snap = require 'snap.svg'

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
  svgUrl: "images/europe_standard.svg"

  initialize: ->
    @model = new Models.Game(Data.Base, parse: true)

  render: ->
    # TODO(rkofman): maybe show a loading screen?
    Snap.load(@svgUrl, @onSvgLoad)

  onSvgLoad: (svgData) =>
    @subViews = {
      map: new Views.Map(model: @model, svgData: svgData)
      header: new Views.Header(model: @model.get('state'))
    }
    @subViews.map.render()
    @subViews.header.render()
