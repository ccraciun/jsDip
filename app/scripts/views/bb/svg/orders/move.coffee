_ = require 'underscore'
backbone = require 'backbone'

Views = {
  BaseSvgView: require '../base_svg'
}

module.exports = class Move extends Views.BaseSvgView

  tagName: 'path'
  xlink: {
    href: "#move"
  }
  className: "move"

  initialize: ->
    super

  render: ->
    startCoords = @model.get('province').get('unitCoordinates')
    targetCoords = @model.get('targetProvince').get('unitCoordinates')
    @$el.attr('d', "M#{startCoords.x},#{startCoords.y} #{targetCoords.x},#{targetCoords.y}")
    @$el.attr('marker-end', "url(#M)")
