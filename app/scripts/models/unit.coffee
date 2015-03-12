BaseModel = require './base'

module.exports = class Unit extends BaseModel
  # @type Unit type for example {A, F}.
  # @loc Location of Unit.
  # @owner Unit owner.
  modelMust: @::['modelMust'].concat ['type', 'loc']
  modelMay: @::['modelMay'].concat ['owner']

  constructor: (unit) ->
    super unit

    @loc = global.defs.canonicalName @loc if @loc
    @type = @type[0].toUpperCase()  # TODO(cosmic): Coordinate with defs.unit_types.

  @fromString: (str) ->
    parts = str.split ' '
    type = parts[0]
    loc = str.slice type.length + 1
    type = type[0].toUpperCase()
    loc = loc.trim()

    return new Unit {'type': type, 'loc': loc}
