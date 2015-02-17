class Date
  constructor: (date, defs) ->
    @year = date.year
    @season = date.season
    @phase = date.phase
    @base = date.base
    @defs = defs ? date.defs

  get_next = (arr, it) ->
    idx = arr.indexOf it
    if idx == -1
      throw "#{arr} doesn't contain #{it}"
    return arr[idx+1]

  next: (defs) =>
    defs = defs ? @defs
    year = @year
    season = @season
    phase = get_next defs.phases[@season] @phase

    if phase
      # Season and year stay the same.
      return new Date year, season, phase, defs

    # New season.
    season = get_next defs.seasons, @season
    if !season
      # New year.
      season = defs.seasons[0]
      year = year + 1

    # Finally get phase, since we changed seasons.
    phase = defs.phases[season][0]

    return new Date year, season, phase, defs
