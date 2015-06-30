Views = {
  Map: require './views/bb/map'
  Header: require './views/bb/header'
}
Models = {
  GameDefinition: require './models/bb/game_definition'
}
Data = {
  EuropeStandardDefs: require '../data/europe_standard_defs.json'
}
window._ = require('underscore')

module.exports = class DiplomacyGame
  constructor: ->
    @map = new Views.Map("images/europe_standard.svg")
    @header = new Views.Header()
    @gameDefinition = new Models.GameDefinition(Data.EuropeStandardDefs)
    # fields in gameDefinition: ["startDate", "belligerents", "seasons",
    # "phases", "headquarters", "subregions", "aliases", "coords", "adjacent"]

    #==============
    # Maybe all of these are just @currentState
    #==============
    # TODO(rkofman): make the following into models that will eventually contain
    # armies and provinces that belong to the belligerents?
    @currentBelligerents = @gameDefinition.get('belligerents')
    @date = @gameDefinition.get('startDate') # todo: parse as gameDate model

    #==============

  init: ->
    @map.render()
    @header.render()
    # @loadDefs()
