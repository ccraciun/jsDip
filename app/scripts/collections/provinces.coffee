_ = require 'underscore'
backbone = require 'backbone'
Models = {
  Province: require '../models/bb/province'
}

module.exports = class Provinces extends backbone.Collection
  model: Models.Province

  set: (models, options) ->
    ret = super
    @initLinks() if options.parse
    ret

  initLinks: ->
    @each (model) ->
      model.initAdjacencyLinks()
      model.initSubregionLinks()

  getMany: (modelNames) ->
    new Provinces(
      _(modelNames).map (name) => @get(name)
    )
