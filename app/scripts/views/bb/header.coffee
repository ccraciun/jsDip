Views = {
  Base: require './base'
}
template = require('../templates/header.hbs')

module.exports = class Header extends Views.Base
  el: '#header'
  template: template
  events: {
    'change .country-selector': "onCountrySelect"
  }

  initialize: (attrs, options) ->
    super

  toJSON: ->
    season: @model.get('season')
    year: @model.get('year')
    phase: @model.get('phase')
    countries: @model.activeCountries().map (c) -> c.get('name')

  onCountrySelect: (e) =>
    countryName = e.currentTarget.value
    countryName = null if _(countryName).isEmpty()
    country = @model.getCountry(countryName)
    @model.set('selectedCountry', country)
