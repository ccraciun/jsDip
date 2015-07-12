backbone = require 'backbone'
_ = require 'underscore'
Views = {
  BaseSvgView: require './base_svg'
}

module.exports = class SupplyCenter extends Views.BaseSvgView

  tagName: 'use'
  xlink: {
    href: "#sc"
  }
  className: "sc"

  initialize: ->
    super
    @listenTo(@model, 'change', @modelUpdated)

  render: ->
    coords = @model.get('supplyCenterCoords')
    @$el.attr('transform', "translate(#{coords.x},#{coords.y})")


  modelUpdated: =>
    # update owner-class if owner has changed.
