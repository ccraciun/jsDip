root = exports ? this

BaseModel = require './base'

module.exports = class GameDate extends BaseModel
  # @year Game year.
  # @season Season of the year (eg, for standard ['spring', 'fall', winter']).
  # @phase Phase of year (eg, for standard ['movement', 'retreat', 'adjustment']).
  modelMust: @::['modelMust'].concat ['phase', 'season', 'year']

  get_next = (arr, it) ->
    idx = arr.indexOf it
    if idx == -1
      throw "#{arr} doesn't contain #{it}"
    return arr[idx+1]

  next: () ->
    # TODO(cosmic): Tests?
    defs = global.defs
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
      'phase': phase}
