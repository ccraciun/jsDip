module.exports = {}
OrderBase = require './order_base'
module.exports = class MoveOrder extends OrderBase

  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+?) (move|->|-) (.+)/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    {
      province: provinces.get(match[2])
      targetProvince: provinces.get(match[4])
    }

  provinceName: () ->
    @get('province').get('name')

  targetProvinceName: ->
    @get('targetProvince').get('name')

  unitType: () ->
    # TODO(rkofman): parse / serialize from tests doesn't
    # play nice with statefulness of board. That's ugly.
    #
    # perhaps an order should know about the theoretical unit being ordered,
    # even if such a unit doesn't exist on the board? In case of real game, that unit
    # can be copied from the board. In others, it can be generated just for
    # use with the order itself? Should same apply to provinces? Not really
    # sure about this direction yet.
    @get('province')?.get('unit')?.get('type')[0].toUpperCase() || @_unitType

  toJSON: () ->
    "#{@unitType()} #{@provinceName()} -> #{@targetProvinceName()}"

  type: ->
    module.exports.type

  pushProvince: (province) ->
    if @get('province')
      @set('targetProvince', province)
      @trigger('construction:complete')
    else
      @set('province', province)

  validNextProvinces: ->
    unit = @get('province').get('unit')
    if unit.get('type') == 'army'
      @get('province').getAdjacentForArmies()
    else if unit.get('type') == 'fleet'
      @get('province').getAdjacentForFleets()


module.exports.type = "move"
module.exports.displayName = "Move"
