_ = require('underscore')
expect = require('chai').expect
Models = {
  Orders:
    Hold: require('../../../../app/scripts/models/bb/orders/Hold')
}

describe 'Models.Orders', ->
  describe '#parse', ->
    describe 'Hold orders', ->
      Hold = Models.Orders.Hold; # less repetitive text entry
      describe 'with bad inputs,', ->
        describe 'not ending with Hold:', ->
          orderText = 'A Marseilles - Gascony'
          describe orderText, ->
            it "should raise syntax exception", ->
              expect(() -> new Hold(orderText, parse: true)).to.throw(Error)
              expect(() -> new Hold(orderText, parse: true)).to.throw(/Can't parse order text/)
        describe 'not starting with "A" or "F"', ->
          orderText = 'Yorkshire Hold'
          describe orderText, ->
            it "should raise syntax exception", ->
              expect(() -> new Hold(orderText, parse: true)).to.throw(Error)
              expect(() -> new Hold(orderText, parse: true)).to.throw(/Can't parse order text/)

      describe 'with good input', ->
        orderText = 'A Burgundy Hold'
        it "should successfully parse order", ->
          expect(() -> new Hold(orderText, parse: true)).to.not.throw(Error)

        it "should successfully parse the Unit being ordered", ->
          # # TODO(rkofman) this should include army type + province.
          # Should probably also test for mismatch of type + location in current state.


