_ = require('underscore')
expect = require('chai').expect
Models = {
  Orders: require('../../../../app/scripts/models/bb/orders')
}

describe 'Models.Orders', ->
  describe '#parse', ->
    describe 'HOLD orders', ->

      describe 'with bad inputs,', ->
        describe 'not ending with HOLD:', ->
          nonHoldOrders = [
            'A Marseilles - Gascony'
            'A Burgundy SUPPORT A Marseilles - Gascony'
            'F North Sea CONVOY A Yorkshire - Norway'
            'A Yorkshire - Norway'
          ]
          _(nonHoldOrders).each (nonHoldOrder) ->
            describe nonHoldOrder, ->
              it "should raise syntax exception", ->
                expect(() -> Models.Orders.parse(nonHoldOrder)).to.throw(Error)
                expect(() -> Models.Orders.parse(nonHoldOrder)).to.throw(/Can't parse order text/)
        describe 'not starting with "A" or "F"', ->
          it "should raise syntax exception", ->
            orderText = "Yorkshire HOLD"
            expect(() -> Models.Orders.parse(orderText)).to.throw(Error)
            expect(() -> Models.Orders.parse(orderText)).to.throw(/Can't parse order text/)

      describe 'with good input', ->
        orderText = 'A Burgundy HOLD'
        it "should successfully parse order", ->
          expect(() -> Models.Orders.parse(orderText)).to.not.throw(Error)

        it "should successfully parse the Unit being ordered", ->
          # # TODO(rkofman) this should include army type + province.
          # Should probably also test for mismatch of type + location in current state.


