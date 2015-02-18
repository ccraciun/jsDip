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

    describe('Judges orders', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        var defs = new dfs.Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));
        for (var testnum in doc) {
            describe('Testcase ' + testnum, function () {
                var state = new st.State(doc[testnum].state);

                var orders = {};
                for (var nation in doc[testnum].orders) {
                    orders[nation] = [];
                    for (var orderStr in doc[testnum].orders[nation]) {
                        var order = ord.Order.fromString(orderStr);
                        order.test_expectedSuccess = doc[testnum].orders[nation][orderStr];
                        orders[nation].push(order);
                    }
                    console.log(doc[testnum].orders[nation]);
                    console.log(orders[nation]);
                }

                var judge = new jg.Judge(defs);

                orders = judge.judge(state, orders);

                it('should judge correctly', function () {
                    for (var nation in orders) {
                        for (var orderNum in orders[nation]) {
                            order = orders[nation][orderNum];
                            order.test_expectedSuccess.should.equal(!order.fail);
                        }
                    }
                });
            });
        }
    });
})();
