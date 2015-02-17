/* global describe, it */
var should = require('should');
var yaml = require('js-yaml');
var fs = require('fs');
var _ = require('underscore');
var order = require('../../app/scripts/models/order');

(function () {
    'use strict';

    var parsesOrder = function (ordr) {
        console.log('parsing ' + ordr);
        var parsed = order.Order.fromString(ordr);
        console.log('parsed ' + JSON.stringify(parsed, null, 4));
        return parsed;
    };

    describe('Parses order', function () {
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
})();
