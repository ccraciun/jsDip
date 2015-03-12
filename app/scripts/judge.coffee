_ = require 'underscore'
Order = require './models/order'


class JudgeOrder extends Order
  # @state Order resolution state in ('guessing', 'resolved', undefined)
  modelMay: @::['modelMay'].concat ['state']

  resolveOrder: ->
    @finishOrder
    @state = 'resolved'

  resolved: ->
    return @state is 'resolved'

  @fromOrder: (order) ->
    orderByAction = {
        'move': MoveOrder,
        'hold': HoldOrder,
        'support': SupportOrder,
        'convoy': ConvoyOrder,
    }

    return new (orderByAction[order.action] ? JudgeOrder) order


class HoldOrder extends JudgeOrder
  constructor: (order) ->
    super order


class MoveOrder extends JudgeOrder
  constructor: (order) ->
    super order

    if @dst == @unit.loc
      @invalidateOrder "Can't move to own location."
      @resolveOrder()
    unless global.defs.adjacent[@dst][@unit.type]
      @invalidateOrder "Can't move fleet to land or army to sea"
      @resolveOrder()


class SupportOrder extends JudgeOrder
  constructor: (order) ->
    super order

    @child = JudgeOrder.fromOrder @child

    if @child.invalid()
      @invalidateOrder @child.whyFail
      @resolveOrder()
    if @child.unit == @unit
      @invalidateOrder "Unit can't support itself. 6.A.8"
      @resolveOrder()
    unless @child.action in ['move', 'hold']
      @invalidateOrder "#{child.str} not a supportable order"
      @resolveOrder()
    unless @child.dst in global.defs.adjacent[@unit.loc][@unit.type]
      @invalidateOrder "Destination not reachable."
      @resolveOrder()


class ConvoyOrder extends JudgeOrder
  constructor: (order) ->
    super order

    @child = JudgeOrder.fromOrder @child

    if @child.invalid()
      @invalidateOrder @child.whyFail
      @resolveOrder()
    if @child.action isnt 'move'
      @invalidateOrder "Could not parse #{child.str} as move."
      @resolveOrder()
    unless @child.unit.type in global.defs.canConvoy[@unit.type]
      @invalidateOrder "Type #{@unit.type} not allowed to convoy type #{@child.unit.type}."
      @resolveOrder()


module.exports = class Judge
  constructor: ->
    @phaseJudge = {
      'Movement': @judgeMovement,
      'Retreat': @judgeNaive,
      'Adjustment': @judgeAdjustment,
    }

  judge: (state, orders) ->
    # Returns a list of judged (annotated with result) orders.

    orders = (JudgeOrder.fromOrder order for order in orders)

    # Common failure cases.
    for order in orders
      if order.owner not in state.activePowers
        order.failOrder "#{order.owner} is not an active power."
      if order.owner not in global.defs.belligerents
        order.failOrder "#{order.owner} is not belligerent."
      if order.fails()
        order.finishOrder()

    # Judge orders for phase.
    @phaseJudge[state.date.phase](state, orders)
    return orders

  applyJudgement: (state, orders) ->
    # Return a new state created by applying judged orders to given state.
    return

  judgeNaive: (state, orders) ->
    for order in orders
      order.finishOrder()

  judgeMovement: (state, orders) ->
    dependencies = []

    # TODO(cosmic): Refactor contender.state is 'resolved' and contender.succeeds()
    adjudicateContenders = (contenders) ->
      contenders = (contender for contender in contenders when not (contender.resolved() and contender.fails()))
      # No opposition.
      return contenders[0] if contenders.length is 1

      support = {}
      for contender in contenders
        if contender.state is 'resolved' and contender.succeeds()
          # Already adjudicated. Should this happen?
          return [contender]
        support[contender.unit.loc] = (order for order in orders \
                                       when (order.action is 'support') \
                                            and (order.child.matches contender) \
                                            and ((resolve order) is 'success')).length

      winners = (order for order in contenders \
                 when support[order.unit.loc] == _.max(_.values(support)))

      return winners

    adjudicateMove = (o) ->
      unless o.dst in global.defs.adjacent[o.unit.loc][o.unit.type]
        # Non-adjacent move. TODO(cosmic): Check for convoys.
        o.failOrder "Non-adjacent move. TODO(cosmic): Convoys!"
        return 'fail'

      contenders = (order for order in orders \
                    when order.action is 'move' and order.dst == o.dst)
      throw "Order not in contenders." if o not in contenders

      if dstUnit = state.forceAt(o.dst)
        dstUnitSuccessfulOrders = (order for order in orders \
                                   when order.unit == dstUnit and resolve o is 'success')
        throw "One unit has multiple successful orders! successes: #{JSON.stringify(dstUnitSuccessfulOrders)}" if dstUnitSuccessfulOrders.length > 1
        if dstUnitSuccessfulOrders[0]?.action is 'hold'
          o.failOrder "Tried to move to destination, but unit holds successfully."
          return 'fail'
        unless dstUnitSuccessfulOrders[0]?.action is 'move'
          # Unit has no successful move orders, it acts as if holding.
          contenders.push new JudgeOrder {'unit': dstUnit, 'action': 'hold', 'dst': o.dst}

      winners = adjudicateContenders contenders

      # Two winners means everyone loses.
      o.failOrder "There was a standoff at the destination."
      return 'fail' if winners.length > 1

      return if o == winners[0] then 'success' else 'fail'

    adjudicateHold = (o) ->
      contenders = (order for order in orders \
                    when order.action is 'move' and order.dst == o.dst)
      contenders.push o

      winners = adjudicateContenders contenders
      # Standoff means holds win
      return 'success' if winners.length > 1

      return if o == winners[0] then 'success' else 'fail'

    adjudicateSupport = (o) ->
      # Direct attack cuts support.
      direct_attack = (order for order in orders \
                       when order.action is 'move' and order.dst == o.unit.loc and \
                            o.unit.loc in global.defs.adjacent[order.unit.loc][order.unit.type])
      if direct_attack.length > 0
        return 'fail'

      # TODO(cosmic): Cutting support through a convoy.

      return 'success'

    adjudicateConvoy = (o) ->
      unless state.forceAt(o.src) == o.child.unit
        o.failOrder "Order to convoy unit #{JSON.stringify(o.child.unit)} doesn't match unit on map #{JSON.stringify(state.forceAt(o.src))}."
        return 'fail'

      contenders = (order for order in orders \
                    when order.action is 'move' and order.dst == o.unit.loc)
      if contenders.length == 0
        return 'success'

      hold = new JudgeOrder {'unit': dstUnit, 'action': 'hold', 'dst': o.dst}
      contenders.push hold
      winners = adjudicateContenders contenders

      if winners.length > 1
        return 'success'
      if  winners[0] == hold
        return 'success'
      return 'fail'

    adjudicate = (o) ->
      # Must not use o.result, instead call resolve to get resolution for dependencies.
      if o.action == 'hold'
        return adjudicateHold o
      else if o.action == 'move'
        return adjudicateMove o
      else if o.action == 'support'
        return adjudicateSupport o
      else if o.action == 'convoy'
        return adjudicateConvoy o
      else
        o.failOrder "Can't perform action #{o.action} during Movement"
        return 'fail'

    resolve = (o) ->
      # Returns 'success' or 'fail'
      # Adapted from `The Math of Adjudication' by Lucas Kruijswijk
      # http://www.diplom.org/Zine/S2009M/Kruijswijk/DipMath_Chp1.htm
      # Also `Creating an Adjudicator' by Martin Bruse
      # http://diplom.org/Zine/F2013R/Bruse/adjudicator.htm
      resetDependenciesToDepth = (depth) ->
        while dependencies.length > dependencies_len_before
          dependencies.pop().state = undefined

      if o.state == 'resolved'
        return o.result
      else if o.state == 'guessing'
        unless o in dependencies
          dependencies.push o
        return o.result
      else
        # Guess order fails, try to adjudicate.
        o.state = 'guessing'
        o.result = 'fail'
        dependencies_len_before = dependencies.length
        result_1 = adjudicate o

        if dependencies_len_before == dependencies.length
          # No added dependencies, can resolve order if not resolved by backup rule already.
          if o.state isnt 'resolved'
            o.state = 'resolved'
            o.result = result_1
          return result_1

        unless o in dependencies
          # Not dependent on own guess, can return a result, but keep state in 'guessing'.
          dependencies.push o
          o.result = result_1
          return result_1

        # Dependent on our own guess, reset dependencies to original state.
        resetDependenciesToDepth dependencies_len_before

        # Guess order succeeds, try to adjudicate.
        o.state = 'guessing'
        o.result = 'success'
        result_2 = adjudicate o

        if result_1 == result_2
          # There is a cycle, but the resolution is the same no matter the guess.
          resetDependenciesToDepth dependencies_len_before
          o.state = 'resolved'
          o.result = result_1
          return result_1

        # Two or no resolutions for the cycle.
        # Cycle occurs in dependencies[dependencies_len_before:]
        backupRule o, dependencies_len_before

        # Backup rule may not have resolved all orders in cycle. Try again.
        return resolve o

      backupRule = (o, dependencies_len_before) ->
        # Paradox or circular dependency with multiple resolutions?
        # http://www.diplom.org/Zine/F1999R/Debate/paradox.html
        # TODO(cosmic): Write actual backup rule.
        resetDependenciesToDepth dependencies_len_before
        o.state = 'resolved'
        o.result = 'fail'

    for order in orders
      order.result = resolve order
      order.finishOrder()

    return orders

  judgeAdjustment: (state, orders) =>
    counts = state.counts
    for order in orders
      if order.action = 'build'
        if counts[order.owner].adjustment < 1
          order.failOrder "No adjustments left to build."
        unless order.unit.loc in global.defs.headquarters[order.owner]
          order.failOrder "Can only build in headquarters."
        if state.forceAt order.unit.loc
          order.failOrder "Can't build if unit is present."
        unless global.defs.adjacent[order.unit.loc][order.unit.type]
          order.failOrder "Can't build unit that can't legally move."
        unless order.fails()
          counts[order.owner].adjustment--
      else if order.action = 'disband'
        unless counts[order.owner].adjustment < 0
          order.failOrder "Can only disband if forced."
        unless state.forceAt order.unit.loc
          order.failOrder "Can't disband nonpresent unit."
        unless state.forceAt(order.unit.loc).power == order.owner
          order.failOrder "Can't disband non owned unit."
        unless order.fails()
          counts[order.owner].adjustment++
      else
        order.failOrder "Can't perform action #{order.action} during adjustment."
      order.finishOrder()

    # Force random disbands. TODO(cosmic): handle this more gracefully, should judge
    # really add orders to the list? If not, move this to applyJudgement?
#    for power, powCounts of counts
#      if powCounts.adjustment < 0
#        units = _.shuffle state.forcesOfPower power
#        for unit in _.take units, -powCounts.adjustment
#          order = new ord.Order {
#            'unit': unit,
#            'action': 'disband'}
#          order.finishOrder()
#          orders.push order

    return orders
