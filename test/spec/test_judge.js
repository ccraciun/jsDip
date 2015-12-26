var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');

require('coffee-script/register');

var Judge = require('../../app/scripts/judge');
var State = require('../../app/scripts/models/state');
var Order = require('../../app/scripts/models/order');
var Defs = require('../../app/scripts/models/defs');

(function () {
    'use strict';

    global.defs = new Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));

    var judgesCorrectly = function (order) {
        (order.succeeds()).should.equal(order.test_expectedSucceeds);
    };

    var judgesNoFailWhyOnSuccess = function (order) {
        if (order.test_expectedSucceeds) {
            should.not.exist(order.whyFail);
        }
    };

    describe('Judge', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        for (var testNum in doc) {
            describe('for Testcase ' + doc[testNum].testCaseID, function () {
                var state = new State(doc[testNum].state);
                var orders = [];
                for (var power in doc[testNum].orders) {
                    for (var orderStr in doc[testNum].orders[power]) {
                        var order = Order.fromString(orderStr);
                        order.owner = power;
                        order.test_expectedSucceeds = doc[testNum].orders[power][orderStr][0];
                        orders.push(order);
                    }
                }

                if (doc[testNum].generateForces) {
                    for (var orderIdx in orders) {
                        var unit = orders[orderIdx].unit;
                        unit.owner = orders[orderIdx].owner;
                        state.forces.push(unit);
                    }
                }

                var judge = new Judge();

                var judged_orders = judge.judge(state, orders);

                for (var orderNum in orders) {
                    var j_o = judged_orders[orderNum];
                    var o = orders[orderNum];
                    j_o.test_expectedSucceeds = o.test_expectedSucceeds;
                    var fun = _.partial(judgesCorrectly, j_o);
                    it('should judge order ' + o.str + ' correctly', fun);
                    if (o.test_expectedSucceeds) {
                        fun = _.partial(judgesNoFailWhyOnSuccess, o);
                        it('should have no fail reasons for successful order ' + o.str, fun);
                    }
                }
            });
        }
    });
})();
