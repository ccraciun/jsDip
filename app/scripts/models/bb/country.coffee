backbone = require 'backbone'
_ = require 'underscore'

Models = {
  Unit: require '../../models/bb/unit'
}

Collections = {
  Units: require '../../collections/units'
}

module.exports = class Country extends backbone.Model
  idAttribute: "name"

  parse: (data, options) ->
    attrs = super
    attrs = @_parseUnits(attrs, options)
    attrs = @_parseProvinces(attrs, options)


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


