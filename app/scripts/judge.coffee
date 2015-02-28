root = exports ? this

_ = require 'underscore'
ord = require './models/order'
unt = require './models/unit'

root.Judge = class Judge
  constructor: () ->
    @phaseJudge = {
      'Movement': @judgeMovement,
      'Retreat': @judgeNaive,
      'Adjustment': @judgeAdjustment,
    }

  judge: (state, orders) ->
    # Return a list of judged (annotated with status) orders.
    orders = _.extend([], orders)

    # Common failure cases.
    for idx, order of orders
      if order.fail?
        order.status = 'resolved'
      if order.owner not in state.activePowers
        order.failOrder "#{order.owner} is not an active power."
      if order.owner not in global.defs.belligerents
        order.failOrder "#{order.owner} is not belligerent."

    # Judge orders for phase.
    @phaseJudge[state.date.phase](state, orders)
    return orders

  applyJudgement: (state, orders) ->
    # Return a new state created by applying judged orders to given state.
    return

  judgeNaive: (state, orders) ->
    for idx, order of orders
      order.finishOrder()

  judgeMovement: (state, orders) ->
    dependencies = []

    adjudicateMove = (o) ->
      return 'success'

    adjudicateHold = (o) ->
      return 'success'

    adjudicateSupport = (o) ->
      if o.child.unit == o.unit
        o.failOrder "Invalid support: unit can't support itself. 6.A.8"
        return 'fail'
      unless o.child.action in ['move', 'hold']
        o.failOrder "Invalid support: #{child.str} not a supportable order."
        return 'fail'
      return 'success'

    adjudicateConvoy = (o) ->
      if o.child.action isnt 'move'
        o.failOrder "Invalid convoy: could not parse #{child.str} as move."
        return 'fail'
      return 'success'

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

    for idx, order of orders
      order.result = resolve order
      order.finishOrder()

    return orders

  judgeAdjustment: (state, orders) =>
    counts = state.counts
    for idx, order of orders
      console.log(JSON.stringify(order))
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
#        for idx, unit of _.take units, -powCounts.adjustment
#          order = new ord.Order {
#            'unit': unit,
#            'action': 'disband'}
#          order.finishOrder()
#          orders.push order

    return orders
