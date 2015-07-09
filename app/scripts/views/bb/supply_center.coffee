backbone = require 'backbone'
_ = require 'underscore'
Views = {
  BaseSvgView: require './base_svg'
}
BaseView = require('./base')

module.exports = class SupplyCenter extends Views.BaseSvgView

  tagName: 'circle'

  initialize: ->
    super
    @listenTo(@model, 'change', @modelUpdated)

  attributes: ->
    coords = @model.get('supplyCenterCoords')
    transform: "translate(#{coords.x},#{coords.y})"
    'data-province-name': @model.get('name')
    class: 'sc Unowned'
    id: "sc#{@model.get('name')}"
    r: 4

  modelUpdated: =>
    # update owner-class if owner has changed.
