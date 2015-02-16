
class State
  constructor: (info) ->
    # Extending a class as constructor?
    for key, value of info
      @[key] = value

  counts: =>
    if !@_counts?
      # Count SCs.
      for power, supplyCenters of @SCs
        @_counts[power] ?= {}
        @_counts[power].SCs = @SCs[power].length

      # Count forces
      for power, forces in @forces
        @_counts[power] ?= {}
        # If custom forces are defined, we might needs defs here.
        @_counts[power].armies = forces.armies.length
        @_counts[power].fleets = forces.fleets.length
        @_counts[power].forces = @_counts[power].armies + @counts[power].fleets
        @_counts[power].adjudment = @_counts[power].SCs - @_counts[power].forces

    return @_counts

  forceAt: (loc) =>
    for power, forces in @forces
      for type, locations in forces
        if loc in locations
          return {'power': power, 'type': type}
