root = exports ? this

base = require './base'

root.Unit = class Unit extends base.BaseModel
  # @type Unit type for example {A, F}.
  # @loc Location of Unit.
  # @owner Unit owner.
  modelMust: @::['modelMust'].concat ['type', 'loc']
  modelMay: @::['modelMay'].concat ['owner']

  constructor: (unit) ->
    super unit

    @loc = global.defs.canonicalName @loc if @loc

  @fromString: (str) ->
    parts = str.split ' '
    type = parts[0]
    loc = str.slice type.length + 1
    type = type[0].toUpperCase()
    loc = loc.trim()

    return new Unit {'type': type, 'loc': loc}

