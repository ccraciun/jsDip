backbone = require 'backbone'
Models = {
  Units: {
    Army: require '../models/bb/units/army'
    Fleet: require '../models/bb/units/fleet'
  }
}

module.exports = class Units extends backbone.Collection
  model: (attrs, options) ->
    if attrs.type == 'fleet'
      new Models.Units.Fleet(attrs, options)
    else
      new Models.Units.Army(attrs, options)

  fleets: ->
    @where type: 'fleet'

  armies: ->
    @where type: 'army'
