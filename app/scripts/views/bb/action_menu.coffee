$ = require 'jquery'
Views = {
  Base: require './base'
}
template = require '../templates/action_menu.hbs'

# Note, this is a work in progress. Click-action handling
# on the menu isn't done yet. Ideally, the menu will listen to
# clicks on its links -- and publish an event to interested
# subscribers.
#
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

  onOrderTypeSelect: (e) ->
    console.log "order selected: ", e

  toJSON: ->
    orderTypes: @types

  render: ->
    super
    @$el.hide()
    @$popoverEl = @$('.orders-popout')
    @$popoverEl.css("position": "absolute");
    $('body').append @el

  show: (x, y) ->
    @$popoverEl.css(left: x, top: y)
    @$el.show()
