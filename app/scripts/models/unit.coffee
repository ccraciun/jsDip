root = exports ? this

root.Unit = class Unit
  constructor: (unit) ->
    # Unit type in {A, F}
    @type = unit.type
    # Location of Unit.
    @loc = unit.loc

  @fromString: (str) ->
    parts = str.split ' '
    type = parts[0]
    loc = str.slice type.length + 1
    type = type[0]
    loc = loc.trim()

    return new Unit {'type': type, 'loc': loc}

