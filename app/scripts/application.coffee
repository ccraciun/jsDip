bootstrap = ->
  # NOTE: If this function gets beyond ~5 lines, it should be refactored.
  $().ready ->
    window.game = new DipEngine() # args here
    game.init()

bootstrap()
