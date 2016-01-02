backbone = require 'backbone'
_ = require 'underscore'

Models = {
  Unit: require '../../models/bb/unit'
}

Collections = {
  Units: require '../../collections/units'
  Orders: require '../../collections/orders'
}

module.exports = class Country extends backbone.Model
  # Attributes:
  #   - name: String, the name of the country.
  #   - provinces: A Collection of provinces owned by this country.
  #   - units: A Collection fleets and armies owned by this country.
  #   - orders: The current Collection of orders entered for this country.

  idAttribute: "name"

  parse: (data, options) ->
    _(super).tap (attrs) =>
      @_parseUnits(attrs, options)
      @_parseProvinces(attrs, options)
      @_parseOrders(attrs, options)

  supplyCenters: ->
    @get('provinces').where(isSupplyCenter: true)

  _parseProvinces: (attrs, options) ->
    attrs.provinces = _(attrs.provinces).map (provinceName) =>
      _(options.allProvinces.get(provinceName)).tap (province) =>
        province.set('owner', @)

  _parseUnits: (attrs, options) ->
    fleets = _(attrs.fleets).map (provinceName) => @_vivifyUnit('fleet', provinceName, options.allProvinces)
    armies = _(attrs.armies).map (provinceName) => @_vivifyUnit('army', provinceName, options.allProvinces)
    attrs.units = new Collections.Units(
      _.union(fleets, armies)
    )
    delete attrs.fleets
    delete attrs.armies

  _parseOrders: (attrs, options) ->
    attrs.orders = new Collections.Orders(attrs.orders, parse: true)

  _vivifyUnit: (type, provinceName, allProvinces) ->
    attrs = {
      type: type
      province: allProvinces[provinceName]
      owner: @
    }
    new Models.Unit(attrs, options)
