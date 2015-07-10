backbone = require 'backbone'
_ = require 'underscore'

Views = {
  BaseSvgView: require './base_svg'
}

module.exports = class UnitView extends Views.BaseSvgView

  tagName: 'use'
  xlink: =>
    return unless @model
    href: "##{@model.get('type')}"

  attributes:
    style: "opacity: .8; fill: #f33;"

  initialize: (options) ->
    super
    @listenTo(@model, 'change', @modelUpdated)

   # id: "sc#{@model.get('name')}"
  render: ->
    coords = @model.get('province').get('unitCoordinates')
    @$el.attr('transform', "translate(#{coords.x},#{coords.y})")
    @_setXlinkAttrs(@$el)

  modelUpdated: =>
    @render()
    # re-render, possibly.
