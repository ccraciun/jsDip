backbone = require 'backbone'
_ = require 'underscore'
SupplyCenter = require '../models/bb/supply_center'

module.exports = class SupplyCenters extends backbone.Collection
  model: SupplyCenter
  initialize: (attrs, options) ->
    super
    @provinces = options.provinces # should this be passed to here?

  parse: (data, options) ->
    _(data).map (coords, provinceName) ->
      {
        coords: coords
        provinceName: provinceName
      }
