backbone = require 'backbone'
_ = require 'underscore'

Collections = {
  Units: require '../../collections/units'
}

module.exports = class Country extends backbone.Model

  parse: (data, options) ->
    attrs = super

    fleets = _(attrs.fleets).map (provinceName) ->
      type: 'fleet'
      province: provinceName
    armies = _(attrs.armies).map (provinceName) ->
      type: 'army'
      province: provinceName
    units = _.union(fleets, armies)
    attrs.units = new Collections.Units(
      units,
      provinces: options.provinces,
      parse: true
    )
    _(attrs).omit 'fleets', 'armies'
