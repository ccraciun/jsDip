backbone = require 'backbone'
BaseOrdersFactory = require './base'

OrderClasses = [
  # order of array is the order in which they will be displayed in the selector UI
  require '../orders/move'
  require '../orders/hold'
  require '../orders/support'
  require '../orders/convoy'
]

module.exports = class MovementOrdersFactory extends BaseOrdersFactory
  orderClasses: OrderClasses

  initialize: (attrs, options) ->
    @orderUnderConstruction = null
    @pendingProvince = null
    @set('actionableProvinces', @initiallyActionableProvinces())
    @set('orders', attrs.country.get('orders'))

  initiallyActionableProvinces: ->
    provincesArr = @get('country').get('units').map (unit) ->
      unit.get('province')
    new backbone.Collection(provincesArr)

  actionableProvinces: ->
    if @orderUnderConstruction
      @orderUnderConstruction.validNextProvinces()
    else
      @initiallyActionableProvinces()

  hasOrderUnderConstruction: ->
    !!@orderUnderConstruction

  pushOrderClass: (orderClass) ->
    @orderUnderConstruction = new orderClass()
    @listenTo(@orderUnderConstruction, 'construction:complete', @onConstructionComplete)
    @pushProvince(@pendingProvince) # potential infinite loop. maybe cleanup this code.
    @pendingProvince = null

  onConstructionComplete: ->
    @get('orders').push @orderUnderConstruction
    @orderUnderConstruction = null
    @pendingProvince = null # probably not necessary.

  pushProvince: (province) ->
    if @orderUnderConstruction
      @orderUnderConstruction.pushProvince(province)
      @updateActionable()
    else
      @pendingProvince = province

  updateActionable: ->
    if @orderUnderConstruction
      @set('actionableProvinces', @orderUnderConstruction.validNextProvinces())
    else
      @set('actionableProvinces', @initiallyActionableProvinces())
