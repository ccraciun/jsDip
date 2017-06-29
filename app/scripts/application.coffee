Views = {
  Game: require('./views/bb/game')
}
$ = require('jquery')


bootstrap = ->
  # NOTE: This function is the entry-point, and should be *extremely* small.
  # Please always keep it well-factored.
  #$().ready ->
    #game = new Views.Game() # args here
    #game.render()

# bootstrap()

bootstrap_playground = ->
  # NOTE: This function is the entry-point, and should be *extremely* small.
  # Please always keep it well-factored.
  $().ready ->
    game = new Views.Game() # args here
    game.render()

    # useful for ease of debugging.
    window.$ = $
    window._ = require('underscore')
    window.game = game
bootstrap_playground()
