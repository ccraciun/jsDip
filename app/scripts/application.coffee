Views = {
  Game: require('./views/bb/game')
}
$ = require('jQuery')


bootstrap = ->
  # NOTE: This function is the entry-point, and should be *extremely* small.
  # Please always keep it well-factored.
  $().ready ->
    game = new Views.Game() # args here
    game.render()

    # useful for ease of debugging.
    window.$ = $
    window._ = require('underscore')
    window.game = game

bootstrap()
