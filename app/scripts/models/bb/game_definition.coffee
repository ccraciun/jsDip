backbone = require('backbone')
Collections = {
  Belligerents: require('../../collections/belligerents')
}

module.exports = class GameDefinition extends backbone.Model
  initialize: ->
    super

  parse: (data, options) ->
    data.belligerents = new Collections.Belligerents(data.belligerents, parse: true)
    super

  seasons: ->
    @get('seasons')
