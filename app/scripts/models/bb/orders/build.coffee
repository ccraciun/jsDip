module.exports = {}
OrderBase = require './order_base'

module.exports = class BuildOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/(build) ([AF]) (.+)$/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[2]
    @province = provinces.get(match[3])

  provinceName: () ->
    @province.get('name')

  unitType: () ->
    @_unitType

  toJSON: () ->
    "Build #{@unitType()} #{@provinceName()}"
