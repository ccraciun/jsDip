root = exports ? this

_ = require 'underscore'
ord = require './models/order'
unt = require './models/unit'

root.Judge = class Judge
  constructor: (defs) ->
    @defs = defs

    @phaseJudge = {
      'Movement': @judgeNaive,
      'Retreat': @judgeNaive,
      'Adjustment': @judgeAdjustment
    }


  failOrder = (order, reason) ->
    # Convenience method to fail an order for a reason.
    order.fail = (order.fail ? []).push reason
    order.status = 'resolved'

  judgeNaive: (state, orders) =>
    for power, powerOrders of orders
      for order of powerOrders
        order.status = 'resolved'

  judgeAdjustment: (state, orders) =>
    for power, powerOrders of orders
      adjustment = state.counts()[power].adjustment
      for order of powerOrders
        if order.action = 'build'
          if adjustment < 1
            failOrder order, "No adjustments left to build."
          if order.unit.loc not in @defs.headquarters[power]
            failOrder order, "Can only build in headquarters."
          if state.forceAt(order.unit.loc)?
            failOrder order, "Can't build if unit is present."
          unless defs.adjacent[order.unit.loc][order.unit.type]
            failOrder order, "Can't build unit that can't legally move."
          unless order.fail
            adjustment--
            order.fail = []
            order.status = 'resolved'
        else if order.action = 'disband'
          unless adjustment < 0
            failOrder order, "Can only disband if forced."
          unless state.forceAt(order.unit.loc)?
            failOrder order, "Can't disband nonpresent unit."
          unless state.forceAt(order.unti.loc).power == power
            failOrder order, "Can't disband non owned unit."
          unless order.fail
            adjustment++
            order.fail = []
            order.status = 'resolved'

      if adjustment < 0
        units = _.shuffle(state.forces[power].armies + state.forces[power].fleets)
        for unit of _.take(units, -adjustment)
          order = new ord.Order {
            'unit': new unt.Unit({'loc': unit}),
            'action': 'disband'}
          order.fail = false
          order.status = 'resolved'
          powerOrders.push(order)

  judge: (state, orders) =>
    for power, powerOrders of orders
      for order of powerOrders
        if order.fail?
          order.status = 'resolved'
        if power not in state.activePowers
          failOrder(order, "#{power} is not an active power.")
        if power not in @defs.belligerents
          failOrder(order, "#{power} is not a belligerent.")
    console.log @phaseJudge[state.date.phase]
    @phaseJudge[state.date.phase](state, orders)
    return orders

  applyJudgement: (state, orders) =>
    return
