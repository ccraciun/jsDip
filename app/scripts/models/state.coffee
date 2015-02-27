root = exports ? this

gd = require './date'

root.State = class State
  constructor: (info) ->
    for key, val of info when val? and key in ['activePowers', 'SCs', 'forces']
      @[key] = val
    @date = new gd.GameDate info.date

  counts: ->
    if !@_counts?
      @_counts = {}
      for _, power of @activePowers
        # Count SCs.
        @_counts[power] = {}
        @_counts[power].SCs = @SCs[power]?.length ? 0

        # Count forces
        # If custom forces are defined, we might needs defs here.
        @_counts[power].armies = @forces[power]?.armies?.length ? 0
        @_counts[power].fleets = @forces[power]?.fleets?.length ? 0
        @_counts[power].forces = @_counts[power].armies + @_counts[power].fleets
        @_counts[power].adjudment = @_counts[power].SCs - @_counts[power].forces

    return @_counts

  forceAt: (loc) ->
    for power, forces of @forces
      for type, locations of forces
        if loc in locations
          return {'power': power, 'type': type}
