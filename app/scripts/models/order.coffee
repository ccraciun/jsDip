BaseModel = require './base'
Unit = require './unit'

# TODO(cosmic): Locations need a class for normalization.

module.exports = class Order extends BaseModel
  # @owner Power giving order.
  # @unit Actor unit.
  # @action Action as string.
  # @src Source unit. Currently only for convoying.
  # @dst Destionation/target location for action.
  # @str String from which order was created (if any).
  # @child Support and convoy actions need to be lent to a specific order.
  #        In particular, we can support holds, but convoy child orders should be moves.
  # @result Result of order in ('fail', 'success', undefined).
  # @whyFail If order fails, list of reasons why.
  modelMust: @::['modelMust'].concat ['owner', 'unit', 'action', 'dst']
  modelMay: @::['modelMay'].concat ['str', 'child', 'src', 'result', 'whyFail']

  constructor: (order) ->
    super order

    for key in ['src', 'dst'] when @[key]
      @[key] = window.defs.canonicalName @[key]
    @unit = new Unit @unit
    @child = new Order @child if @child?

  failOrder: (why) ->
    @result = 'fail'
    (@whyFail = @whyFail ? []).push why

  invalidateOrder: (why) ->
    @result = 'invalid'
    (@whyFail = @whyFail ? []).push why

  finishOrder: ->
    @result = @result ? if @whyFail then 'fail' else 'success'

  invalid: ->
    return @result is 'invalid'

  fails: ->
    return @result in ['fail', 'invalid']

  succeeds: ->
    return not @fails()


  @fromString: (str) ->
    try
      # startsWith 'build': build (unit)
      if 0 == str.toLowerCase().indexOf 'build'
        action = 'build'
        unit = Unit.fromString (str.slice 6)

      # endsWith 'hold': (unit) hold
      else if 'hold' == str.toLowerCase().match('hold$')?[0]
        # TODO(cosmic): match/slice hold and holds
        action = 'hold'
        unit = Unit.fromString (str.slice 0, str.length - 5)
        dst = unit.loc

      # (unit) supports (order)
      else if (parts = str.split(/supports?/i)).length > 1
        action = 'support'
        unit = Unit.fromString parts[0].trim()
        child = Order.fromString parts[1].trim()
        dst = child.dst

      # (unit) convoy (unit) - (destination)
      else if (parts = str.split(/convoys?/i)).length > 1
        action = 'convoy'
        unit = Unit.fromString parts[0].trim()
        child = Order.fromString parts[1].trim()
        src = child.unit.loc
        dst = child.dst

      # (unit) - (destination)
      else if (parts = str.split '-').length > 1
        action = 'move'
        parts = str.split '-'
        unit = Unit.fromString parts[0].trim()
        dst = parts[1].trim()

      # declaring just (unit) is a hold, fallback case.
      else
        action = 'hold'
        unit = Unit.fromString str
        dst = unit.loc
    catch error
      whyFail = (whyFail ? []).push error

    if child?.whyFail
      whyFail = (whyFail ? []) + child.whyFail

    if whyFail?
      result = 'fail'

    return new Order {'unit': unit, \
                      'action': action, \
                      'src': src, \
                      'dst': dst, \
                      'child': child, \
                      'str': str, \
                      'result': result,
                      'whyFail': whyFail}
