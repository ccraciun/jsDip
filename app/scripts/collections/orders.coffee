backbone = require 'backbone'

module.exports = class OrdersBase extends backbone.Collection

  model: (attrs, options) ->
    # TODO(rkofman): Parse order-type here, and build correct order?
    # Otherwise, pass the responsibility to some other actor.
    # Perhaps, a function in the models/bb/orders module?
