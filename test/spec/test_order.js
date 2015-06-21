/* global describe, it */
var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');

require('coffee-script/register');

var Defs = require('../../app/scripts/models/defs');
var Order = require('../../app/scripts/models/order');

var root = (typeof exports !== "undefined" && exports !== null) ? exports : this;

(function () {
    'use strict';

    global.defs = new Defs(JSON.parse(fs.readFileSync('app/data/europe_standard_defs.json', 'utf8')));

    var parsesOrder = function (ordr, ans) {
        var parsed = Order.fromString(ordr);
        if (ans !== undefined) {
            if (ans.child) {
                ans.child = new Order(ans.child);
            }
            var answer = new Order(ans);
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
