### global describe, it ###

should = require('should')
yaml = require('js-yaml')
fs = require('fs')
_ = require('underscore')
require 'coffee-script/register'
Defs = require('../../app/scripts/models/defs')
Order = require('../../app/scripts/models/order')
root = if typeof exports != 'undefined' and exports != null then exports else this
do ->
  'use strict'
  global.defs = new Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')))

  parsesOrder = (ordr, ans) ->
    parsed = Order.fromString(ordr)
    if ans != undefined
      if ans.child
        ans.child = new Order(ans.child)
      answer = new Order(ans)
      parsed.should.eql answer
    return

  describe 'Parses all orders', ->
    doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'))
    for testnum of doc
      for nation of doc[testnum].orders
        for ordr of doc[testnum].orders[nation]
          fun = _.partial(parsesOrder, ordr)
          it 'should parse order ' + ordr, fun
    return
  describe 'Correctly parses orders', ->
    doc = yaml.safeLoad(fs.readFileSync('test/data/orders_parsed.yml', 'utf8'))
    for testnum of doc
      ordr = doc[testnum].order
      parsed = doc[testnum].parsed
      fun = _.partial(parsesOrder, ordr, parsed)
      it 'should correctly parse order ' + ordr, fun
    return
  return
