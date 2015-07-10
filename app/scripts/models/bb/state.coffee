backbone = require 'backbone'
_ = require 'underscore'
Models = {
  GameDate: require './game_date'
}
Collections = {
  Countries: require '../../collections/countries'
}

module.exports = class State extends backbone.Model
  parse: (data, options) ->
    _(super).tap (attrs) ->
      attrs.date = new Models.GameDate(attrs.date, parse: true)
      countries = _(attrs.countries).map (val, key) ->
        _(val).extend name: key
      attrs.countries = new Collections.Countries(
        countries,
        provinces: options.provinces,
        parse: true
      )

  activeCountries: ->
    null
