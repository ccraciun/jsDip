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
    'click .actionable': 'onActionableClick'
    'mouseenter .actionable': 'onActionableEnter'
    'mouseleave .actionable': 'onActionableLeave'

  initialize: (options) ->
    super
    @state = @model.get('state')
    @provinces = @model.get('provinces')
    Snap(@el).append options.svgData if options.svgData

    @svgProvinces = Snap('#Provinces')
    @svgSupplyCenters = Snap('#SupplyCenters')
    @svgUnits = Snap('#Units')
    @svgOrders = Snap('#Orders')

    @listenTo(@provinces, 'change:view:hover', @onProvinceHover)
    @initOrderEntry() # should depend on current State Machine.

  initOrderEntry: ->
    @listenTo(@state, 'change:ordersFactory', @onOrdersFactoryChange)
    @onOrdersFactoryChange(@state, @state.get('ordersFactory')) if @state.get('ordersFactory')


  render: (svgData=null) ->
    @model.get('provinces').each (province) =>
      @renderProvince(province)
      @renderSupplyCenter(province) if province.get('isSupplyCenter')
      @renderUnit(province) if province.get('unit')

  renderProvince: (province) ->
    subregions = province.get('subregions')
    unless subregions.isEmpty()
      subregions.each (province) => @renderProvince province
      return # the parent province doesn't exist in SVG.
    svgProvince = @getSvgProvince(province)
    svgProvince.attr('data-province', province.get('name'))
    svgProvince.addClass('province')
    if province.get('owner')
      svgProvince.attr('data-owner', province.get('owner').get('name'))


  renderSupplyCenter: (province) ->
    supplyCenterView = new Views.SupplyCenter(model: province)
    supplyCenterView.render()
    @svgSupplyCenters.append(supplyCenterView.el)
    svgEl = Snap(supplyCenterView.el)
    svgEl.attr('data-province', province.get('name'))
    if province.get('owner')
      svgEl.attr('data-owner', province.get('owner').get('name'))

  renderUnit: (province) ->
    unit = province.get('unit')
    unitView = new Views.Unit(model: unit)
    unitView.render()
    @svgUnits.append(unitView.el)
    svgEl = Snap(unitView.el)
    svgEl.attr('data-province', province.get('name'))
    svgEl.attr('data-owner', unit.get('owner').get('name'))

  ## DOM events
  onActionableEnter: (e) ->
    provinceName = Snap(e.currentTarget).attr('data-province')
    province = @provinces.get(provinceName)
    province.set('view:hover', true)

  onActionableLeave: (e) ->
    provinceName = Snap(e.currentTarget).attr('data-province')
    province = @provinces.get(provinceName)
    province.set('view:hover', false)

  onActionableClick: (e) ->
    provinceName = Snap(e.currentTarget).attr('data-province')
    province = @model.get('provinces').get(provinceName)
    if @ordersFactory.currentOrder
      @ordersFactory.push province
    else
      console.log "TODO(rkofman): Get order type, and then create an order"
      # @ordersFactory.createOrder(type, province)

  ## Model events
  onOrdersFactoryChange: (state, ordersFactory) ->
    previousFactory = state.previous('ordersFactory')
    @stopListening(previousFactory) if previousFactory

    @ordersFactory = ordersFactory
    @setActionableProvinces ordersFactory.actionableProvinces()

  onProvinceHover: (province, isHovered) ->
    svgEl = @getSvgProvince(province)
    svgEl.toggleClass 'hover', isHovered

  ## helpers

  getSvgProvince: (province) ->
    @svgProvinces.select("##{province.htmlId()}")

  removeHover: ->
    @svgProvinces.select('.hover')?.removeClass('hover')

  removeActionable: ->
    Snap.selectAll(".actionable")?.forEach (svgEl) ->
      svgEl.removeClass('actionable')

  setActionableProvinces: (provinces) ->
    @removeHover()
    @removeActionable()
    _(provinces).each (province) =>
      name = province.get('name')
      Snap.selectAll("[data-province='#{name}']").forEach (svgEl) ->
        svgEl.addClass('actionable', true)
