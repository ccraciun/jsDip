# Future-proofing, for modularized code.
HistoryBox = require './views/history_box'
DipMap = window.DipMap
Menu = require './views/menu'
State = require './models/state'
Defs = require './models/defs'

module.exports = class DipEngine
  constructor: () ->
    @dipMap = new DipMap("#map")
    @historyBox = new HistoryBox("#messageBox")
    @defs = null
    @state = null

  init: ->
    $.when(@loadMap("data/europe_standard_defs.json", "images/europe_standard.svg"),
           @loadStateUrl("data/europe_standard_start.json"))
      .then @finishInit

  finishInit: =>
    @menu = new Menu(@dipMap, @state)
    @showTime()

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

  loadMap: (defsUrl, mapSvgUrl) =>
    # TODO(rkofman): just return the getJSON deferred object
    console.log "deferring loadMap"
    deferred = new jQuery.Deferred()

    # TODO(ccraciun): Support loading jDip map data..
    $.getJSON(defsUrl).done((data) =>
      globals.defs = new Defs(data) # not sure if correct, but unreaks some .js
      @defs = data
      @dipMap.setDefs data
      console.log "done loadMap"
      deferred.resolve()
    ).fail (jqxhr, textStatus, error) ->
      console.error(textStatus + ', ' + error)
      deferred.reject jqxhr, textStatus, error

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
