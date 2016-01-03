$ = require 'jquery'
_ = require 'underscore'
Views = {
  Base: require './base'
}
template = require '../templates/action_menu.hbs'

# How to use me:
#   actionMenu = new ActionMenu(arrayOforderTypes)
#   actionMenu.render()
#   actionMenu.show(event.pageX, event.pageY) # assuming a click-event trigger
module.exports = class ActionMenu extends Views.Base
  types: ["move", "hold", "support", "convoy"]
  template: template

  events: {
    'click .popout-blanket': 'remove'
    'click .order-type': 'onOrderTypeSelect'
  }

  initialize: (@orderClasses) ->

  onOrderTypeSelect: (e) ->
    type = $(e.currentTarget).data('orderType')
    orderClass = _(@orderClasses).find (type: type)
    @trigger('select', orderClass)
    @remove()

  toJSON: ->
    orderClasses: _(@orderClasses).map (orderClass) ->
      type: orderClass.type
      displayName: orderClass.displayName

  render: ->
    super
    @$el.hide()
    @$popoverEl = @$('.orders-popout')
    @$popoverEl.css("position": "absolute");
    $('body').append @el

  show: (x, y) ->
    @$popoverEl.css(left: x, top: y)
    @$el.show()
