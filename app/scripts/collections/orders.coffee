backbone = require 'backbone'

Models = {
  Orders: require('../models/bb/orders')
}

module.exports = class OrdersBase extends backbone.Collection

  model: (attrs, options) ->
    parser = Models.Orders.getParser(options.allProvinces)
    parser.parse attrs
