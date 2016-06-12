module.exports = {}
OrderBase = require './order_base'
module.exports = class HoldOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+) Hold/)
    throw new Error("Can't parse order text") unless match
    @_unitType = match[1]
    @province = provinces.get(match[2])

  provinceName: () ->
  	@province.get('name')

  unitType: () ->
  	@_unitType

  toJSON: () ->
  	"#{@unitType()} #{@provinceName()} Hold"



module.exports.type = "hold"
module.exports.displayName = "Hold"
