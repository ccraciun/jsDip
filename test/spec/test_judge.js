var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');

var jg = require('../../app/scripts/judge');
var st = require('../../app/scripts/models/state');
var ord = require('../../app/scripts/models/order');
var dfs = require('../../app/scripts/models/defs');

var root = (typeof global !== "undefined" && global !== null) ? global : this;

(function () {
    'use strict';

    global.defs = new dfs.Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));

    var judgesCorrectly = function (order) {
        (order.succeeds()).should.equal(order.test_expectedSucceeds);
    };

    var judgesNoFailWhyOnSuccess = function (order) {
        if (order.test_expectedSucceeds) {
            if(order.whyFail) {
                console.log(JSON.stringify(order, null, 2));
            }
            should.not.exist(order.whyFail);
        }
    };

    describe('Judge', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        for (var testNum in doc) {
            describe('for Testcase ' + doc[testNum].testCaseID, function () {
                var state = new st.State(doc[testNum].state);
                var orders = [];
                for (var power in doc[testNum].orders) {
                    for (var orderStr in doc[testNum].orders[power]) {
                        var order = ord.Order.fromString(orderStr);
                        order.owner = power;
                        order.test_expectedSucceeds = doc[testNum].orders[power][orderStr];
                        orders.push(order);
                    }
                }

                var judge = new jg.Judge();

                orders = judge.judge(state, orders);

                for (var orderNum in orders) {
                    var o = orders[orderNum];
                    var fun = _.partial(judgesCorrectly, o);
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
