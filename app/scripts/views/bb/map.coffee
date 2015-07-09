backbone = require('backbone')
$ = require 'jQuery'
Snap = require('snap.svg')
Collections = {
  SupplyCenters: require('../../collections/supply_centers')
}
Views = {
  Base: require './base'
  SupplyCenter: require('./supply_center')
}
Data = {
  coords: require '../../../data/coords.json'
}

module.exports = class Map extends Views.Base
  el: '#map'
  initialize: (options) ->
    super
    @svgUrl = options.svgUrl

  render: ->
    Snap.load(@svgUrl, @onSvgLoad)

  onSvgLoad: (svg_data) =>
    Snap(@el).append svg_data
    @renderSCs()

  renderSCs: ->
    @model.supplyCenters().each (province) ->
      provinceEl = $("##{province.get('name')}")
      supplyCenterView = new Views.SupplyCenter(model: province)
      supplyCenterView.render()
      provinceEl.append(supplyCenterView.el)
