should = require('should')
yaml = require('js-yaml')
fs = require('fs')
_ = require('underscore')
require 'coffee-script/register'
Judge = require('../../app/scripts/judge')
State = require('../../app/scripts/models/state')
Order = require('../../app/scripts/models/order')
Defs = require('../../app/scripts/models/defs')
do ->
  'use strict'
  global.defs = new Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')))

  judgesCorrectly = (order) ->
    order.succeeds().should.equal order.test_expectedSucceeds
    return

  judgesNoFailWhyOnSuccess = (order) ->
    if order.test_expectedSucceeds
      should.not.exist order.whyFail
    return

  describe 'Judge', ->
    doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'))
    for testNum of doc
      describe 'for Testcase ' + doc[testNum].testCaseID, ->
        state = new State(doc[testNum].state)
        orders = []
        for power of doc[testNum].orders
          for orderStr of doc[testNum].orders[power]
            order = Order.fromString(orderStr)
            order.owner = power
            order.test_expectedSucceeds = doc[testNum].orders[power][orderStr][0]
            orders.push order
        if doc[testNum].generateForces
          for orderIdx of orders
            unit = orders[orderIdx].unit
            unit.owner = orders[orderIdx].owner
            state.forces.push unit
        judge = new Judge
        judged_orders = judge.judge(state, orders)
        for orderNum of orders
          j_o = judged_orders[orderNum]
          o = orders[orderNum]
          j_o.test_expectedSucceeds = o.test_expectedSucceeds
          fun = _.partial(judgesCorrectly, j_o)
          it 'should judge order ' + o.str + ' correctly', fun
          if o.test_expectedSucceeds
            fun = _.partial(judgesNoFailWhyOnSuccess, o)
            it 'should have no fail reasons for successful order ' + o.str, fun
        return
    return
  return
