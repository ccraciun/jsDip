DipEngine = window.DipEngine

$().ready ->
  window.game = new DipEngine() # args here
  game.init()
