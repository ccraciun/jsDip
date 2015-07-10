backbone = require 'backbone'
Models = {
  Unit: require '../models/bb/unit'
}

module.exports = class Units extends backbone.Collection
  model: Models.Unit

  fleets: ->
    @where type: 'fleet'

  armies: ->
    @where type: 'army'
