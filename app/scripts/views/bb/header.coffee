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
    @date = @model.get('date')

  toJSON: ->
    {
      season: @date.get('season')
      year: @date.get('year')
      phase: @date.get('phase')
      countries: @model.activeCountries().map (c) -> c.get('name')
    }

  onCountrySelect: (e) =>
    selectedCountry = e.currentTarget.value
    selectedCountry = null if _(selectedCountry).isEmpty()
    @model.set('selectedCountry', selectedCountry)
