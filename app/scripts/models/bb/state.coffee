backbone = require 'backbone'
_ = require 'underscore'

Collections = {
  Countries: require '../../collections/countries.coffee'
}

Models = {
  OrderFactories: {
    Adjust: require './order_factories/adjust.coffee'
    Movement: require './order_factories/movement.coffee'
    Retreat: require './order_factories/retreat.coffee'
  }
}

module.exports = class State extends backbone.Model
  initialize: (attrs, options) ->
    super

  parse: (data, options) ->
    _(super).tap (attrs) =>
      countries = _(attrs.countries).map (val, key) =>
        _(val).extend name: key
      attrs.countries = new Collections.Countries(
        countries
        state: @
        phase: attrs.phase
        allProvinces: options.provinces
        parse: true
      )

  activeCountries: ->
    @get('countries').active()

  getCountry: (name) ->
    @get('countries').get name

  units: ->
    @get('countries').units()

  startOrderEntry: (countryName) ->
    country = @getCountry(countryName)

    orderFactory = Models.OrderFactories[@get('phase')]
    throw "Can't parse phase." unless orderFactory
    @set('ordersFactory', new orderFactory(country: country))
