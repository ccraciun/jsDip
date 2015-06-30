backbone = require('backbone')

module.exports = class BaseView extends backbone.View
  render: ->
    @$el.html(@template(@toJSON())) if @template
    @trigger('render')
    return super

  toJSON: ->
    return @model.toJSON() if @model && 'toJSON' of @model
    return @collection.toJSON if @collection && 'toJSON' of @collection
    return @model if @model
    return @collection if @collection
    return {}
