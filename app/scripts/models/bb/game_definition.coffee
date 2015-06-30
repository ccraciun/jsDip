backbone = require('backbone')

module.exports = class GameDefinition extends backbone.Model
  initialize: ->
    super

  parse: (data, options) ->
    super

  belligerents: ->
    @get('belligerents')

  seasons: ->
    @get('seasons')
