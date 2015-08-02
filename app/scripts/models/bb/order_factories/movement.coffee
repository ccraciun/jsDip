BaseOrdersFactory = require './base'

Models = {
  Orders: {
    Hold: require '../orders/hold'
    Move: require '../orders/move'
    Support: require '../orders/support'
    Convoy: require '../orders/convoy'
  }
}

module.exports = class MovementOrders extends BaseOrdersFactory
  actionableProvinces: ->
    @get('country').get('units').map (unit) ->
      unit.get('province')
