DipEngine = window.DipEngine

$().ready ->
  dip = new DipEngine() # args here
  $.when(dip.loadMap("data/europe_standard_defs.json", "images/europe_standard.svg"),
         dip.loadStateUrl("data/europe_standard_start.json"))
    .then dip.initMenu

