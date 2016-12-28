module.exports = {}
OrderBase = require './order_base'
module.exports = class MoveOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+?) (move|->|-) (.+)/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    @province = provinces.get(match[2])
    @targetProvince = provinces.get(match[4])

  provinceName: () ->
    @province.get('name')

  targetProvinceName: ->
    @targetProvince.get('name')

  unitType: () ->
    @_unitType

  toJSON: () ->
    "#{@unitType()} #{@provinceName()} -> #{@targetProvinceName()}"

  type: ->
    "move"


module.exports.type = "move"
module.exports.displayName = "Move"
