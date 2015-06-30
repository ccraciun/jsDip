backbone = require('backbone')
Snap = require('snap.svg')

module.exports = class Map extends backbone.View
  el: '#map'
  initialize: (svg_url) ->
    @svg_url = svg_url

  render: ->
    Snap.load(@svg_url, @onSvgLoad)

  onSvgLoad: (svg_data) =>
    Snap(@el).append svg_data
    # @wrapping_el.append svg_data
