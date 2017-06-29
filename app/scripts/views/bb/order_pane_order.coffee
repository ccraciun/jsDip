Views = {
  Base: require './base'
}
template = require('../templates/order_pane_order.hbs')

module.exports = class OrderPane extends Views.Base
  tagName: 'li'
  className: 'order-pane-order'
  template: template
  events: {
    'click .orders-pane-delete': 'onOrderDelete'
  }

  render: ->
    super

  onOrderDelete: (event) ->
    event.preventDefault()
    @model.destroy()

  toJSON: ->
    @model.toJSON()
