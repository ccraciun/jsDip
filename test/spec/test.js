/* global describe, it */

(function () {
    'use strict';

    describe('Truth test', function () {
        describe('maybe describe it some more here?', function () {
            it('should describe truth as true.', function () {
              true.should.be.true;
            });
        });
    });
})();
