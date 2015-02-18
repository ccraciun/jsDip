root = exports ? this

unt = require './unit'

# TODO(cosmic): Locations need a class for normalization.
root.Order = class Order
  constructor: (order) ->
    # @unit Actor unit.
    # @action Action as string.
    # @src Source unit. Currently only for convoying.
    # @dst Destionation/target location for action.
    # @str String from which order was created (if any).
    # @child Support and convoy actions need to be lent to a specific order.
    #        In particular, we can support holds, but convoy child orders should be moves.
    # @fail Does order fail, and if so, why?
    for key, val of order when val? and key in ['unit', 'action', 'src', 'dst', 'str', 'child', 'fail']
      @[key] = val

  @fromString: (str) ->
    # TODO(cosmic): Pull all order failure logic out of this class!
    try
      # startsWith 'build': build (unit)
      if 0 == str.toLowerCase().indexOf 'build'
        action = 'build'
        unit = unt.Unit.fromString (str.slice 6)

      # endsWith 'hold': (unit) hold
      else if 'hold' == str.toLowerCase().match('hold$')?[0]
        # TODO(cosmic): match/slice hold and holds
        action = 'hold'
        unit = unt.Unit.fromString (str.slice 0, str.length - 5)

      # (unit) supports (order)
      else if (parts = str.split(/supports?/i)).length > 1
        action = 'support'
        unit = unt.Unit.fromString parts[0].trim()
        child = Order.fromString parts[1].trim()
        if child.unit == unit
          fail = (fail ? []).push "Invalid support: unit can't support itself."
        if child.action in ['build', 'convoy']
          fail = (fail ? []).push "Invalid support: #{child.str} not a supportable order."
        if child.fail
          fail = (fail ? []).push child.fail

      # (unit) convoy (unit) - (destination)
      else if (parts = str.split(/convoys?/i)).length > 1
        action = 'convoy'
        unit = unt.Unit.fromString parts[0].trim()
        child = Order.fromString parts[1].trim()
        src = child.unit.loc
        dst = child.dst
        if child.action != 'move'
          fail = (fail ? []).push "Invalid convoy: could not parse #{child.str} as move."
        if child.fail
          fail = (fail ? []).push child.fail

      # (unit) - (destination)
      else if (parts = str.split '-').length > 1
        action = 'move'
        parts = str.split '-'
        unit = unt.Unit.fromString parts[0].trim()
        dst = parts[1].trim()

      # declaring just (unit) is a hold, fallback case.
      else
        action = 'hold'
        unit = unt.Unit.fromString str
    catch error
      fail = (fail ? []).push error

    return new Order {'unit': unit, \
                      'action': action, \
                      'src': src, \
                      'dst': dst, \
                      'child': child, \
                      'str': str, \
                      'fail': fail}