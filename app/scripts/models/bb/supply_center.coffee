backbone = require 'backbone'

module.exports = class SupplyCenter extends backbone.Model
  initialize: ->
    super

  parse: (data, options) ->
    [x,y] = data.coords.split(',')
    {
      x: x
      y: y
      provinceName: data.provinceName
    }
