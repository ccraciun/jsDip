BaseOrdersFactory = require './base'

OrderClasses = [
  # order == display order in UI.
  require '../orders/move'
  require '../orders/hold'
  require '../orders/support'
  require '../orders/convoy'
]

module.exports = class MovementOrdersFactory extends BaseOrdersFactory
  orderClasses: OrderClasses

  initialize: ->
    @provinces = []
    @orders = []
    @currentOrder = null

  actionableProvinces: ->
    @get('country').get('units').map (unit) ->
      unit.get('province')

  push: (province) ->
    @provinces.push province
    console.log "current provinces in order factory: ", @provinces
