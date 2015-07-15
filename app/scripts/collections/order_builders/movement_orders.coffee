OrdersBase = require './base'

Models = {
  Orders: {
    Hold: require '../../models/bb/orders/hold'
    Move: require '../../models/bb/orders/move'
    Support: require '../../models/bb/orders/support'
    Convoy: require '../../models/bb/orders/convoy'
  }
}

module.exports = class MovementOrders extends OrdersBase
  model: Models.Orders.Move

  actionableProvinces: ->
    @country.get('units').map (unit) ->
      unit.get('province')
