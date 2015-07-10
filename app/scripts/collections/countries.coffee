backbone = require 'backbone'
Models = {
  Country: require '../models/bb/country'
}

module.exports = class Countries extends backbone.Collection
  model: Models.Country

  active: ->
    @filter((country) ->
      !country.forces().blank() &&
      !country.supplyCenters().blank()
    )
