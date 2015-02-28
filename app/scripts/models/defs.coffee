root = exports ? this

root.Defs = class Defs
  constructor: (defs) ->
    # @startDate    considered the start of the game for turn calculations.
    # @belligerents involved powers.
    # @seasons      list of seasons in each year.
    # @phases       map of season -> list of phases in that season.
    # @headquarters list of headquarters per belligerent.
    # @force_types  list of force types, (e.g. [A, F] as army, fleet.
    # TODO(cosmic): @coords does not belong here!
    # @subregions   regions with multiple coasts.
    # @aliases      aliases for each region
    # @coords       coordinates where forces will be drawn for each region.
    # @adjacent     adjacency list per region by force type.
    for key, val of defs when val? and key in ['startDate', 'belligerents', 'seasons', 'phases', 'headquarters', 'force_types', 'coords', 'subregions', 'aliases', 'adjacent']
      @[key] = val

    @canonical = {}
    for name, aliases of @aliases
      for alias in aliases
        @canonical[alias] = name

  canonicalName: (name) ->
    return @canonical[name.toLowerCase().replace('_', ' ')]
