# Future-proofing, for modularized code.
HistoryBox = require './views/history_box'
# DipMap = window.DipMap
Defs = require './models/defs'
Header = require('./views/bb/header')
Map = require './views/bb/map'
Menu = require './views/menu'
State = require './models/state'

module.exports = class DipEngine
  constructor: ->
    @map = new Map("images/europe_standard.svg")
    @header = new Header()
    # @historyBox = new HistoryBox("#messageBox")

  init: ->
    @map.render()
    @header.render()
    @loadDefs()

  printCounts: ->
    for pow in @state.counts()
      # TODO(ccraciun): Multiple types of forces here.
      forceDescription = [
        "#{counts[pow].SCs} SCs"
        "#{counts[pow].armies} armies"
        "#{counts[pow].fleets} fleets."
      ].join(', ')
      @historyBox.putLine "#{pow} has #{forceDescription}", pow

  showTime: ->
    dateString = [@state.date.year, @state.date.season, @state.date.phase].join(" ")
    $("#map_interface #status #date").text dateString

  loadDefs: ->
    $.getJSON(defsUrl).done((data) =>
      window.defs = new Defs(data) # not sure if correct, but unreaks some .js
      @defs = data
      # @dipMap.setDefs data
      console.log "done loadMap"
      deferred.resolve()

  loadMap: (defsUrl, mapSvgUrl) =>
    # TODO(rkofman): just return the getJSON deferred object
    console.log "deferring loadMap"
    deferred = new jQuery.Deferred()

    @dipMap.loadMapFromUrl mapSvgUrl
    deferred.promise()

  setState: (newState) ->
    @state = new State(newState)
    @printCounts
    @showTime
    @dipMap.drawState @state
    for pow in @state.activePowers
      $("<span class=\"separator\"> | </span>").appendTo $("#menu #powers")
      $("<a href=\"#\" class=\"menu-item power " + pow.toLowerCase() + "\"><span>" + pow + "</span></a>").appendTo $("#menu #powers")

  loadStateUrl: (stateUrl) =>
    # TODO(rkofman): just return the getJSON deferred object
    console.log "deferring loadStateUrl"
    deferred = new jQuery.Deferred()
    $.getJSON(stateUrl).done((newState) =>
      @setState newState
      console.log "done loadStateUrl"
      deferred.resolve()
    ).fail (jqxhr, textStatus, error) ->
      console.error(textStatus + ', ' + error)
      deferred.reject jqxhr, textStatus, error

    deferred.promise()
