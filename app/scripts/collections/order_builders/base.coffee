backbone = require 'backbone'


module.exports = class OrdersBase extends backbone.Collection
  initialize: (models, options) ->
    @setCountry(options?.country)

  setCountry: (country) ->
    @country = country

  model: (attrs, options) ->
    # TODO(rkofman): Parse order-type here, and build correct order?
    # Otherwise, pass the responsibility to some other actor.
    # Perhaps, a function in the models/bb/orders module?

  actionableProvinces: ->
    throw "Each order-builder collection must implement this method."
