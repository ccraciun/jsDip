class Unit
  constructor (unit) ->
    @loc = unit.loc
    @type = unit.type

class Order
  constructor: (order) ->
    # Actor.
    @unit = new Unit order.unit
    # Action.
    @act = order.act
    # Source
    @src = new Unit order.src
    # Destination
    @dst = order.dst

  fromString: (str) ->
    if str.toLowerCase().startsWith 'build'
      act = 'build'
      str = str.slice 6
    if str.toLowerCase().endsWith 'hold'
      act = 'hold'
      str = str.slice 0, str.length - 5

    u_type = str.split()[0]
    str = str.slice u_type.length + 1

    if act?
      dst = src = loc = str
      s_type = u_type
    else
      parts = str.split '-'
      src = parts[0].trim()
      dst = parts[1].trim()

      if (parts = src.split(/support/i)).length > 1
        act = 'support'
        loc = parts[0].trim()
        s_type = parts[1].split()[0]
        src = parts[1].slice s_type.length + 1
      else if (parts = src.split(/convoy/i)).length > 1
        act = 'convoy'
        loc = parts[0].trim()
        s_type = parts[1].split()[0]
        src = parts[1].slice s_type.length + 1
      else
        act = 'move'



    return new Order {'unit': {'type': u_type, 'loc': loc}, \
                      'act': act, \
                      'src': {'type': s_type, 'loc': src}, \
                      'dst': dst}

