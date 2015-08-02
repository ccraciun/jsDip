backbone = require 'backbone'


module.exports = class BaseOrderFactory extends backbone.Model

  actionableProvinces: ->
    throw "Each order-factory collection must implement this method."
