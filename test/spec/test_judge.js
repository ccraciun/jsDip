var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');

var jg = require('../../app/scripts/judge');
var st = require('../../app/scripts/models/state');
var ord = require('../../app/scripts/models/order');
var dfs = require('../../app/scripts/models/defs');

(function () {
    'use strict';

    describe('Judge', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        var defs = new dfs.Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));
        for (var testnum in doc) {
            describe('for Testcase ' + doc[testnum].testCaseID, function () {
                var state = new st.State(doc[testnum].state);
                var orders = [];
                for (var power in doc[testnum].orders) {
                    for (var orderStr in doc[testnum].orders[power]) {
                        var order = ord.Order.fromString(orderStr);
                        order.owner = power;
                        order.test_expectedSucceeds = doc[testnum].orders[power][orderStr];
                        orders.push(order);
                    }
                }

                var judge = new jg.Judge(defs);

                orders = judge.judge(state, orders);

                for (var orderNum in orders) {
                    var o = orders[orderNum];
                    it('should judge order ' + o.str + ' correctly', function () {
                        (o.succeeds()).should.equal(o.test_expectedSucceeds);
                    });
                    if (o.test_expectedSucceeds) {
                        it('should have no fail reasons for order ' + o.str, function () {
                            should.not.exist(o.whyFail);
                        });
                    }
                }
            });
        }
    });
})();
