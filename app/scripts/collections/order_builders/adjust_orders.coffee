OrdersBase = require './base'

Models = {
  Orders: {
    Disband: require '../../models/bb/orders/disband'
    Build: require '../../models/bb/orders/build'
  }
}

module.exports = class AdjustOrders extends OrdersBase
