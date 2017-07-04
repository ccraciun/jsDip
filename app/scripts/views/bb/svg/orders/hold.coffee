_ = require 'underscore'
backbone = require 'backbone'

Views = {
  BaseSvgView: require '../base_svg'
}

module.exports = class Hold extends Views.BaseSvgView

  tagName: 'use'
  xlink: {
    href: "#hold"
  }
  className: "hold"

  initialize: ->
    super

  render: ->
    coords = @model.get('province').get('unitCoordinates')
    @$el.attr('transform', "translate(#{coords.x},#{coords.y})")
