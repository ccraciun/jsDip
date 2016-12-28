module.exports = {}
OrderBase = require './order_base'
module.exports = class MoveOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+?) (HOLD|H)/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    @province = provinces.get(match[2])

  provinceName: () ->
  	@province.get('name')

  unitType: () ->
  	@_unitType

  toJSON: () ->
  	"#{@unitType()} #{@provinceName()} Hold"

  type: ->
    module.exports.type


module.exports.type = "hold"
module.exports.displayName = "Hold"
