BaseModel = require './base'

module.exports = class Defs extends BaseModel
  # @startDate    considered the start of the game for turn calculations.
  # @belligerents involved powers.
  # @seasons      list of seasons in each year.
  # @phases       map of season -> list of phases in that season.
  # @headquarters list of headquarters per belligerent.
  # @force_types  list of force types, (e.g. [A, F] as army, fleet.
  # @canConvoy     What unit types can convoy what unit types.
  # @subregions   regions with multiple coasts.
  # @aliases      aliases for each region
  # TODO(cosmic): @coords does not belong here!
  # @coords       coordinates where forces will be drawn for each region.
  # @adjacent     adjacency list per region by force type.
  modelMust: @::['modelMust'].concat ['startDate', 'belligerents', 'seasons', 'phases',
                                      'headquarters', 'force_types', 'canConvoy',
                                      'subregions','aliases', 'adjacent']
  modelMay: @::['modelMay'].concat ['coords']

  constructor: (defs) ->
    super defs

    @canonical = {}
    for name, aliases of @aliases
      for alias in aliases
        @canonical[alias] = name
        @canonical[alias.replace(/\s/g, '')] = name

  canonicalName: (name) ->
    return @canonical[name.toLowerCase().replace('_', ' ')]
