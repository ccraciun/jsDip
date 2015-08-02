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
  events:
    # 'mouseenter *': 'onMouseEnter'
    # 'mouseleave *': 'onMouseLeave'
    'click .actionable': 'onActionableClick'

  onActionableClick: (e) ->
    console.log "actionable clicked", e
    console.log "clicked: #{$(e.currentTarget).attr('data-name')}!"

  onMouseEnter: (e) ->
    console.log 'mouse enter', e

  onMouseLeave: (e) ->
    console.log 'mouse leave', e

  initialize: (options) ->
    super
    @state = @model.get('state')
    @initOrderEntry() # should depend on current State Machine.

  initOrderEntry: ->
    @listenTo(@state, 'change:ordersFactory', @onOrdersFactoryChange)

  onOrdersFactoryChange: (state, ordersFactory) ->
    @setActionableProvinces ordersFactory.actionableProvinces()

  setActionableProvinces: (provinces) ->
    @$("*.actionable").each (index, element) ->
      Snap(element).removeClass('actionable')
    _(provinces).each (province) =>
      name = province.get('name')
      @$("[data-province='#{name}']").each (index, element) ->
        Snap(element).toggleClass('actionable', true)

  render: (svgData=null) =>
    Snap(@el).append svgData if svgData
    @renderSubviews()

  renderSubviews: ->
    # TODO(rkofman): Supply Centers and Units might deserve their own layers,
    # so they are always drawn on top.
    @model.get('provinces').each (province) ->
      provinceEl = @$("##{province.htmlId()}")
      provinceEl.attr('data-name', province.get('name'))
      provinceEl.attr('data-province', province.get('name'))
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
