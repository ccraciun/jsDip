root = exports ? this

unt = require './unit'

# TODO(cosmic): Locations need a class for normalization.
root.Order = class Order
  constructor: (order) ->
    # Actor unit.
    @unit = order.unit
    # Action.
    @act = order.act
    # Source unit.
    @src = order.src
    # Destination.
    @dst = order.dst
    # String from which order was created (if any)
    @str = order.str
    # Support actions needs to be lent to a specific order.
    # In particular, we can support holds.
    @sup = order.sup
    # Does order fail, and if so, why?
    @fail = order.fail

  @fromString: (str) ->
    # TODO(cosmic): Pull all order failure logic out of this class!
    try
      # startsWith 'build': build (unit)
      if 0 == str.toLowerCase().indexOf 'build'
        act = 'build'
        unit = Unit.fromString (str.slice 6)

      # endsWith 'hold': (unit) hold
      else if 'hold' == str.toLowerCase().match('hold$')?[0]
        # TODO(cosmic): match/slice hold and holds
        act = 'hold'
        unit = Unit.fromString (str.slice 0, str.length - 5)

      # (unit) supports (order)
      else if (parts = str.split(/supports?/i)).length > 1
        act = 'support'
        console.log "Parsing support from #{parts[0]} for #{parts[1]}"
        unit = Unit.fromString parts[0].trim()
        sup = Order.fromString parts[1].trim()
        if sup.unit == unit
          fail = "Invalid support: unit can't support itself. " + (fail ? '')
        if sup.act in ['build', 'convoy']
          fail = "Invalid support: #{sup.str} not a supportable order. " + (fail ? '')
        if sup.fail
          fail = sup.fail + (fail ? '')

      # (unit) convoy (unit) - (destination)
      else if (parts = str.split(/convoys?/i)).length > 1
        act = 'convoy'
        unit = Unit.fromString parts[0].trim()
        sup = Order.fromString parts[1].trim()
        src = sup.src
        dst = sup.dst
        if sup.act != 'move'
          fail = "Invalid convoy: could not parse #{sup.str} as move. "
        if sup.fail
          fail = sup.fail + (fail ? '')

      # (unit) - (destination)
      else if (parts = str.split '-').length > 1
        act = 'move'
        parts = str.split '-'
        console.log "For #{ str } have parts: #{ parts }"
        unit = Unit.fromString parts[0].trim()
        dst = parts[1].trim()

      # declaring just (unit) is a hold, fallback case.
      else
        act = 'hold'
        unit = Unit.fromString str
    catch error
      fail = (fail ? '') + error

    return new Order {'unit': unit, \
                      'act': act, \
                      'src': src, \
                      'dst': dst, \
                      'sup': sup, \
                      'str': str, \
                      'fail': fail}
