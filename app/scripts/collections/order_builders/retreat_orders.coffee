OrdersBase = require './base'

Models = {
  Orders: {
    Retreat: require '../../models/bb/orders/retreat'
    Disband: require '../../models/bb/orders/disband'
  }
}

module.exports = class RetreatOrders extends OrdersBase
