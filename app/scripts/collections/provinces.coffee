_ = require 'underscore'
backbone = require 'backbone'
Models = {
  Province: require '../models/bb/province'
}

module.exports = class Provinces extends backbone.Collection
  model: Models.Province

  set: (data, options) ->
    ret = super
    return ret unless options.parse
    @initLinks()
    @parseCoords(options.coords)
    return ret

  initLinks: ->
    @each (model) ->
      model.initAdjacencyLinks()
      model.initSubregionLinks()

  getMany: (modelNames) ->
    new Provinces(
      _(modelNames).map (name) => @get(name)
    )

  parseCoords: (coords) ->
    _(coords.provinces).map (coordinateString, provinceName) =>
      province = @get(provinceName)
      [x, y] = coordinateString.split(',')
      province.set({
        unitCoordinates: {x: x, y: y}
      })
      supplyCenterCoords = coords.supplyCenters[provinceName]
      if supplyCenterCoords
        [scX, scY] = supplyCenterCoords.split(',')
        province.set({
          supplyCenterCoords: {x: scX, y: scY}
          isSupplyCenter: true
        })
