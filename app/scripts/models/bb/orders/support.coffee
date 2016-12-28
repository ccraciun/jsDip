OrderBase = require './order_base'
module.exports = class SupportOrder extends OrderBase


  parse: (text, options) ->
    provinces = options.provinces
    orderParser = options.orderParser

    match = text.match(/^([AF]) (.+?) (supports|supp|support) (.+)$/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    @province = provinces.get(match[2])
    try
      @set('subOrder', orderParser.parse(match[4]))
    catch e
      throw new Error("Can't parse Support sub-order: `#{match[4]}`. Original exception: #{e}")
    if @get('subOrder').type() not in ['move', 'hold']
      throw new Error("Can't parse Support sub-order. Only 'move' and 'hold' types are allowed. Got: #{@get('subOrder').type()})")
      

  sourceProvinceName: ->
    @get('subOrder').provinceName()

  provinceName: () ->
    @province.get('name')

  targetProvinceName: ->
    @get('subOrder').targetProvinceName()

  unitType: () ->
    @_unitType

  toJSON: () ->
    "#{@unitType()} #{@provinceName()} Supports #{@get('subOrder').toJSON()}"

  type: ->
    module.exports.type

module.exports.type = "support"
module.exports.displayName = "Support"
