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
      countries: @model.get('activeBelligerents')
    }

  onCountrySelect: (e) =>
    console.log e.currentTarget.value
