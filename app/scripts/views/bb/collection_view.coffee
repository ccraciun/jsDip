Views = {
  Base: require './base'
}

module.exports = class CollectionView extends Views.Base

  initialize: (options) ->
    @subViewOptions = options.subViewOptions
    @subViewConstructor = options.subView

  render: ->
    super
    # TODO(rkofman): we should be listening to add/remove and doing the right thing
    # for each item rather than re-rendering the entire list each time.
    @listenTo(@collection, 'update', @redraw)
    @redraw()
    return @

  redraw: ->
    _(@subViews).each (view) -> view.remove()
    @subViews = @collection?.map (model) =>
      opts = _({model: model}).extendOwn(@subViewOptions)
      view = new @subViewConstructor(opts)
      view.render()
      @$el.append(view.el)
      view

