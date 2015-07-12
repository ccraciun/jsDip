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
    @state = @model.get('state')
    @initOrderEntry() # should depend on current State Machine.

  initOrderEntry: ->
    @listenTo(@state, 'change:selectedCountry', @onCountryChange)

  onCountryChange: (state, countryName) =>
    console.log @model.get('state').get('selectedCountry')

  render: (svgData=null) =>
    Snap(@el).append svgData if svgData
    @renderSubviews()

  renderSubviews: ->
    # TODO(rkofman): Supply Centers and Units might deserve their own layers,
    # so they are always drawn on top.
    @model.get('provinces').each (province) ->
      provinceEl = @$("##{province.htmlId()}")
      if province.get('owner')
        provinceEl.attr('data-owner', province.get('owner').get('name'))

      if province.get('isSupplyCenter')
        supplyCenterView = new Views.SupplyCenter(model: province)
        supplyCenterView.render()
        provinceEl.append(supplyCenterView.el)
      if province.get('unit')
        unitView = new Views.Unit(model: province.get('unit'))
        unitView.render()
        provinceEl.append(unitView.el)
