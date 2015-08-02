backbone = require 'backbone'
Models = {
  Country: require '../models/bb/country'
}

module.exports = class Countries extends backbone.Collection
  model: Models.Country

  active: ->
    @filter((country) ->
      not(_(country.get('units')).isEmpty() and _(country.get('supplyCenters')).isEmpty())
    )

  units: ->
    _(@map((country) -> country.get('units'))).flatten()
