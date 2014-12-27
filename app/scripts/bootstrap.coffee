# Future-proofing, for modularized code.
HistoryBox = window.HistoryBox
DipMap = window.DipMap
Menu = window.Menu

class window.Engine
  constructor: () ->
    @dipMap = new DipMap("#map")
    @historyBox = new HistoryBox("#messageBox")
    @defs = null
    @state = null

  printCounts: (state) ->
    for pow of state.counts()
      # TODO(ccraciun): Multiple types of forces here.
      description = [
        "#{counts[pow].SCs} SCs"
        "#{counts[pow].armies} armies"
        "#{counts[pow].fleets} fleets."
      ].join(', ')
      historyBox.putLine "#{pow} has #{description}", pow

  showTime: (state) ->
    # TODO(rkofman): refactor so the view-updating code is in the map view.
    dateString = [@state.date.year, @state.date.season, @state.date.phase].join(" ")
    $("#map_interface #status #date").text dateString

  loadMap: (defsUrl, mapSvgUrl, mapCssUrl) ->
    console.log "deferring loadMap"
    deferred = new jQuery.Deferred()

    # TODO(ccraciun): Support loading jDip map data..
    $.getJSON(defsUrl).done((data) ->
      @defs = data
      @dipMap.setDefs data
      console.log "done loadMap"
      deferred.resolve()
    ).fail (jqxhr, textStatus, error) ->
      jQueryAjaxErrorHandler jqxhr, textStatus, error
      deferred.reject jqxhr, textStatus, error

    dipMap.loadMapFromUrl mapSvgUrl
    loadjscssfile mapCssUrl, "css"  if mapCssUrl isnt `undefined`
    deferred.promise()

  setState = (newState) ->
    state = new State(newState)
    printCounts state
    showTime state
    dipMap.drawState state
    for i of state.active
      pow = state.active[i]
      jQuery("<span class=\"separator\"> | </span>").appendTo jQuery("#menu #powers")
      jQuery("<a href=\"#\" class=\"menu-item power " + pow.toLowerCase() + "\"><span>" + pow + "</span></a>").appendTo jQuery("#menu #powers")

  loadStateUrl = (stateUrl) ->
    console.log "deferring loadStateUrl"
    deferred = new jQuery.Deferred()
    jQuery.getJSON(stateUrl).done((newState) ->
      setState newState
      console.log "done loadStateUrl"
      deferred.resolve()
    ).fail (jqxhr, textStatus, error) ->
      jQueryAjaxErrorHandler jqxhr, textStatus, error
      deferred.reject jqxhr, textStatus, error

    deferred.promise()


$().ready bootstrap
    $.when(loadMap("data/europe_standard_defs.json", "images/europe_standard.svg"), loadStateUrl("data/europe_standard_start.json")).then ->
      new Menu(dipMap, state)
