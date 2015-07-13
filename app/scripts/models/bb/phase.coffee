backbone = require 'backbone'
_ = require 'underscore'

Collections = {
  Countries: require '../../collections/countries.coffee'
}

module.exports = (attrs, options) ->
  # Look Ma, a polymorphic constructor!
  new Phase(attrs, options) # can be a subclass.

class Phase extends backbone.Model
  initialize: (attrs, options) ->
    super

  parse: (data, options) ->
    _(super).tap (attrs) ->
      countries = _(attrs.state).map (val, key) ->
        _(val).extend name: key
      attrs.state = new Collections.Countries(
        countries,
        allProvinces: options.provinces,
        parse: true
      )

  activeCountries: ->
    @get('state').activeCountries()

  units: ->
    @get('state').units()

