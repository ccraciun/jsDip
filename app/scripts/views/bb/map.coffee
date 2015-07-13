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
    @phase = @model.get('phase')
    @initOrderEntry() # should depend on current State Machine.

  initOrderEntry: ->
    @listenTo(@phase, 'change:selectedCountry', @onCountryChange)

  onCountryChange: (state, country) =>
    previousCountry = state.previous('selectedCountry')
    if previousCountry
      @makeActionable previousCountry.get('units'), false
      @undelegateEvents()
    if country
      @makeActionable country.get('units')
      @delegateEvents {
        "click .actionable": (e) -> console.log "clicked: #{$(e.currentTarget).attr('data-name')}!"
      }


  makeActionable: (units, flag=true) ->
    units.each (unit) =>
      province = unit.get('province')
      provinceEl = @$("##{province.htmlId()}")
      Snap(provinceEl[0]).toggleClass('actionable', flag)

  render: (svgData=null) =>
    Snap(@el).append svgData if svgData
    @renderSubviews()

  renderSubviews: ->
    # TODO(rkofman): Supply Centers and Units might deserve their own layers,
    # so they are always drawn on top.
    @model.get('provinces').each (province) ->
      provinceEl = @$("##{province.htmlId()}")
      provinceEl.attr('data-name', province.get('name'))
      Snap(provinceEl[0]).addClass('province')
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
