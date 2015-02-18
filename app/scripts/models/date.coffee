root = exports ? this

root.GameDate = class GameDate
  constructor: (date, defs) ->
    @year = date.year
    @season = date.season
    @phase = date.phase
    @defs = defs ? date.defs

  get_next = (arr, it) ->
    idx = arr.indexOf it
    if idx == -1
      throw "#{arr} doesn't contain #{it}"
    return arr[idx+1]

  next: (defs) =>
    # TODO(cosmic): Tests?
    defs = defs ? @defs
    year = @year
    season = @season
    phase = get_next defs.phases[@season] @phase

    unless phase?
      # New season.
      season = get_next defs.seasons, @season
      if !season
        # New year.
        season = defs.seasons[0]
        year = year + 1

      # Finally get phase, since we changed seasons.
      phase = defs.phases[season][0]

    return new GameDate {
      'year': year,
      'season': season,
      'phase': phase,
      'defs': defs }
