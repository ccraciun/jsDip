backbone = require 'backbone'
_ = require 'underscore'

Models = {
  Unit: require '../../models/bb/unit'
}

Collections = {
  Units: require '../../collections/units'
}

module.exports = class Country extends backbone.Model
  # Attributes:
  #   - name: String, the name of the country.
  #   - provinces: A collection of provinces owned by this country.
  #   - units: A collection fleets and armies owned by this country.
  #   - orders: The current collection of orders entered for this country.

  idAttribute: "name"

  parse: (data, options) ->
    attrs = super
    attrs = @_parseUnits(attrs, options)
    attrs = @_parseProvinces(attrs, options)
    attrs = @_parseOrders(attrs, options)

  supplyCenters: ->
    @get('provinces').where(isSupplyCenter: true)

  supplyCenterDelta: ->
    @supplyCenters().count() - @get('units').count()


  _parseProvinces: (attrs, options) ->
    attrs.provinces = _(attrs.provinces).map (provinceName) =>
      _(options.allProvinces.get(provinceName)).tap (province) =>
        province.set('owner', @)
    attrs

  _parseUnits: (attrs, options) ->
    fleets = _(attrs.fleets).map (provinceName) => @_vivifyUnit('fleet', provinceName, options.allProvinces)
    armies = _(attrs.armies).map (provinceName) => @_vivifyUnit('army', provinceName, options.allProvinces)
    attrs.units = new Collections.Units(
      _.union(fleets, armies)
    )
    _(attrs).omit 'fleets', 'armies'

  _parseOrders: (attrs, options) ->
    orders = options.state.buildOrdersCollection(options.phase)
    orders.set(attrs.orders, parse: true)
    orders.setCountry(@)
    attrs.orders = orders
    attrs

  _vivifyUnit: (type, provinceName, allProvinces) ->
    attrs = {
      type: type
      province: provinceName
    }
    options = {
      allProvinces: allProvinces
      owner: @
      parse: true
    }
    new Models.Unit(attrs, options)


