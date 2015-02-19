/* global describe, it */
var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');
var order = require('../../app/scripts/models/order');

(function () {
    'use strict';

    var parsesOrder = function (ordr, ans) {
        var parsed = order.Order.fromString(ordr);
        if (ans !== undefined) {
            if (ans.child) {
                ans.child = new order.Order(ans.child);
            }
            var answer = new order.Order(ans);
            parsed.should.eql(answer);
        }
    };

    describe('Parses all orders', function () {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/rule_tests.yml', 'utf8'));
        for (var testnum in doc) {
            for (var nation in doc[testnum].orders) {
                for (var ordr in doc[testnum].orders[nation]) {
                    var fun = _.partial(parsesOrder, ordr);
                    it('should parse order ' + ordr, fun);
                }
            }
        }
    });

    describe('Correctly parses orders', function() {
        var doc = yaml.safeLoad(fs.readFileSync('test/data/orders_parsed.yml', 'utf8'));
        for (var testnum in doc) {
            var ordr = doc[testnum].order;
            var parsed = doc[testnum].parsed;
            var fun = _.partial(parsesOrder, ordr, parsed);
            it('should correctly parse order ' + ordr, fun);
        }
    });
})();
