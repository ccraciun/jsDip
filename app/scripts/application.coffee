DiplomacyGame = require('./diplomacy')
$ = require('jQuery')

bootstrap = ->
  # NOTE: If this function gets beyond ~5 lines, it should be refactored.
  $().ready ->
    window.game = game = new DiplomacyGame() # args here
    game.init()

bootstrap()
