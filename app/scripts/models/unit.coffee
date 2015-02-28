root = exports ? this

root.Unit = class Unit
  # TODO(cosmic): All model classes use this boilerplate constructor, have them inherit
  # this off a base class? Model attributes in {must, may}
  constructor: (unit) ->
    # @type Unit type for example {A, F}.
    # @loc Location of Unit.
    # @owner Unit owner.
    for key, val of unit when val? and key in ['type', 'loc', 'owner']
      @[key] = val

  @fromString: (str) ->
    parts = str.split ' '
    type = parts[0]
    loc = str.slice type.length + 1
    type = type[0]
    loc = loc.trim()

    return new Unit {'type': type, 'loc': loc}

