backbone = require 'backbone'
_ = require 'underscore'

Collections = {
  Countries: require '../../collections/countries.coffee'
  OrderBuilders: {
    Movement: require '../../collections/order_builders/movement_orders.coffee'
    Retreat: require '../../collections/order_builders/retreat_orders.coffee'
    Adjust: require '../../collections/order_builders/adjust_orders.coffee'
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

  buildOrdersCollection: (phase) ->
    # NOTE: I don't like this implementation with phase passed-in, but since
    # this gets called during #parse, we can't yet use @get('phase')...
    orderCollectionClass = Collections.OrderBuilders[phase]
    throw "Can't parse phase." unless orderCollectionClass
    new orderCollectionClass()
