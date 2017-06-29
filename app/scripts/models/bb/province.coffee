_ = require 'underscore'
backbone = require 'backbone'

module.exports = class Province extends backbone.Model
  idAttribute: "name"

  initialize: (attributes, options) ->
    super

  initSubregionLinks: ->
    return unless @get('subregions')
    @set('subregions', @_vivifyProvinces @get('subregions'))
    @get('subregions').each (subregion) =>
      subregion.set 'parentRegion', @
    @on 'change:owner', =>
      @get('subregions').each (subregion) =>
        subregion.set('owner', @get('owner'))

  initAdjacencyLinks: ->
    vivifiedAdjacencies = {}
    for type, modelNames of @get('adjacent')
      # type is 'A' or 'F'. Shoreline provinces will appear in both. 
      vivifiedAdjacencies[type] = @_vivifyProvinces modelNames
    @set('adjacent', vivifiedAdjacencies, silent: true)

  getAdjacentForArmies: ->
    @get('adjacent')['A']

  getAdjacentForFleets: ->
    @get('adjacent')['F']

  htmlId: ->
    @get('name').replace(/\s/g, "_").replace(/\(/g, "_").replace(/\)/g, "");

  _vivifyProvinces: (provinceNames) ->
    _(@collection.getMany(provinceNames)).tap (subCollection) ->
      throw "Bad data encountered." if subCollection.contains(undefined)

  # not sure if this method is needed...
  # keeping around briefly in case it comes up.
  # unitTypes: ->
  #   _(@adjacencyMap).omit((provinces) -> _(provinces).isEmpty()).keys
