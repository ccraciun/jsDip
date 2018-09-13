module.exports = class Menu
  constructor: (map, state) ->
    @state = state
    @map = map
    @$menuEl = $('#menu')
    @$mapInterfaceEl = $('#map_interface')
    @listen()
    @turnOrders = {}

  listen: ->
    @$menuEl.find('.power').click @clickPower
    @$mapInterfaceEl.find('.done').click @clickDone
    @$mapInterfaceEl.find('.end-phase').click @clickEndPhase

  clickPower: (evt) =>
    power = evt.target.textContent # TODO(rkofman): use a data-attribute.
    if @collectOrders
      @turnOrders[@selectedPower()] = @collectOrders()
    @collectOrders = @map.listenOrders(power, @state)
    @selectPower(power)

  clickDone: (evt) =>
    console.log('clicked done...');
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
    @$menuEl.find('.selected').removeClass('selected')
    @$mapInterfaceEl[0].className = '';
    for power in Object.keys(@turnOrders)
        console.log('element and power:', power, @$menuEl.find('.' + power.toLowerCase()));
        @$menuEl.find('.' + power.toLowerCase()).addClass('has-orders');

  selectPower: (power) ->
    @deselectPowers()
    @$menuEl.find(".#{power.toLowerCase()}").addClass('selected');
    @$mapInterfaceEl[0].className = power.toLowerCase();

  selectedPower: ->
    selected = @$menuEl.find('.selected')[0].textContent # TODO(rkofman): use a data-attribute

  printOrders: (orders) ->
    console.log('Current turn orders:')
    for name, orders in @turnOrders
      console.log("For #{name}")
      for order in orders
        console.log order.toStr()
    console.log(@turnOrders)
