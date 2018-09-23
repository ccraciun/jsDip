backbone = require 'backbone'
_ = require 'underscore'
Views = {
  BaseSvgView: require './base_svg'
  svgHold: require './orders/hold'
  svgMove: require './orders/move'
}

module.exports = class OrdersList extends Views.BaseSvgView

  tagName: 'g'
  xlink: {
    href: "#Orders"
  }

  initialize: ->
    super

  render: ->
    super
    # TODO(rkofman): we should be listening to add/remove and doing the right thing
    # for each item rather than re-rendering the entire list each time.
    # @listenTo(@collection, 'update', @redraw)
    @redraw()
    return @

  redraw: ->
    _(@subViews).each (view) -> view.remove()
    @subViews = @collection?.map (model) =>
      if model.type() == 'hold'
        view = new Views.svgHold model: model
      if model.type() == 'move'
        view = new Views.svgMove model: model
      if view
        view.render()
        Snap(@el).append view.el
        view

