module.exports = {}
OrderBase = require './order_base'

module.exports = class DisbandOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/disband ([AF]) (.+)$/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    @province = provinces.get(match[2])

  provinceName: () ->
    @province.get('name')

  unitType: () ->
    @_unitType

  toJSON: () ->
    "Disband #{@unitType()} #{@provinceName()}"


# module.exports.type = "move"
# module.exports.displayName = "Move"
