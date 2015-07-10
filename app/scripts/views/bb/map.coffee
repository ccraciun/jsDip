backbone = require 'backbone'
$ = require 'jQuery'

Snap = require 'snap.svg'
Collections = {
  SupplyCenters: require '../../collections/supply_centers'
}
Views = {
  Base: require './base'
  SupplyCenter: require './supply_center'
  Unit: require './unit'
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
    @renderSubviews()
    # @renderUnits()

  renderSubviews: ->
    @model.get('provinces').each (province) ->
      provinceEl = @$("##{province.htmlId()}")
      if province.get('isSupplyCenter')
        supplyCenterView = new Views.SupplyCenter(model: province)
        supplyCenterView.render()
        provinceEl.append(supplyCenterView.el)
      if province.get('unit')
        unitView = new Views.Unit(model: province.get('unit'))
        unitView.render()
        provinceEl.append(unitView.el)
