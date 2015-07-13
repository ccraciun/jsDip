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
    phase: require '../../../data/start_phase.json'
    provinces: require '../../../data/provinces.json'
    coords: require '../../../data/coords.json'
  }
}

module.exports = class DiplomacyGame extends Views.Base
  svgUrl: "images/europe_standard.svg"
  initialize: ->
    @model = new Models.Game(Data.Base, parse: true)
    @subViews = {
      map: new Views.Map(model: @model)
      header: new Views.Header(model: @model.get('phase'))
    }

  render: ->
    # TODO(rkofman): maybe show a loading screen?
    Snap.load(@svgUrl, @onSvgLoad)

  onSvgLoad: (svgData) =>
    @subViews.map.render(svgData)
    @subViews.header.render()

  renderSubViews: ->
    for view in _(@subViews).values()
      view.render()
