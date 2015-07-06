backbone = require('backbone')
Snap = require('snap.svg')
Collections = {
  SupplyCenters: require('../../collections/supply_centers')
}
Data = {
  coords: require '../../../data/coords.json'
}

module.exports = class Map extends backbone.View
  el: '#map'
  initialize: (svg_url) ->
    @svg_url = svg_url
    @coords = Data.coords
    @supplyCenters = new Collections.SupplyCenters(Data.coords.supplyCenters, parse: true)

  render: ->
    Snap.load(@svg_url, @onSvgLoad)

  onSvgLoad: (svg_data) =>
    Snap(@el).append svg_data
    @initSCs()

  initSCs: ->
    _(_(@coords.supplyCenters).keys()).each (provinceName) ->
