module.exports = class Menu
  selector: '#menu'
  constructor: (map, state) ->
    @state = state
    @map = map
    @$el = $(@selector)
    @listen()
    @turnOrders = {}

  listen: ->
    @$el.find('.power').click @clickPower
    @$el.find('.done').click @clickDone
    @$el.find('.end-phase').click @clickEndPhase

  clickPower: (evt) =>
    power = evt.target.textContent # TODO(rkofman): use a data-attribute.
    if @collectOrders
      @turnOrders[@selectedPower()] = @collectOrders()
    @collectOrders = @map.listenOrders(power, @state)
    @selectPower(power)

  clickDone: (evt) =>
    if @collectOrders
      @turnOrders[@selectedPower()] = @collectOrders()
      @collectOrders = null
      @deselectPowers()
      @printOrders(@turnOrders);

  clickEndPhase: (e) =>
    @clickDone()
    for power in @state.activePowers
      console.log("#{power} is active but has no orders.") unless power of @turnOrders
      # WIP(ccraciun): Stuff here.
      newState = window.judge.judge(@state, @turnOrders);
      console.log(newState);

  deselectPowers: =>
    @$el.find('.selected').removeClass('selected')

  selectPower: (power) ->
    @deselectPowers()
    @$el.find(".#{power.toLowerCase()}").addClass('selected');

  selectedPower: ->
    selected = @$el.find('.selected')[0].textContent # TODO(rkofman): use a data-attribute

  printOrders: (orders) ->
    console.log('Current turn orders:')
    for name, orders in @turnOrders
      console.log("For #{name}")
      for order in orders
        console.log order.toStr()
    console.log(@turnOrders)
