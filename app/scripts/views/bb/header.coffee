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

  render: ->
    super
    @model.startOrderEntry("England") ## TODO: (test code! do not commit.)

  toJSON: ->
    season: @model.get('season')
    year: @model.get('year')
    phase: @model.get('phase')
    countries: @model.activeCountries().map (c) -> c.get('name')

  onCountrySelect: (e) =>
    countryName = e.currentTarget.value
    @model.startOrderEntry(countryName)
