_ = require 'underscore'
Backbone = require 'backbone'
expect = require('chai').expect
Models = {
  Orders:
    Hold: require('../../../../app/scripts/models/bb/orders/hold')
  Province: require('../../../../app/scripts/models/bb/province')
}

Hold = Models.Orders.Hold; # less repetitive text entry

describe 'Models.Orders.Hold', ->
  describe 'with a collection of Provinces to parse against', ->
    province1 = new Models.Province({name: 'Province 1'})
    province2 = new Models.Province({name: 'Province 2'})
    provinces = new Backbone.Collection([province1, province2], model: Models.Province)

    describe '#parse', ->
      describe 'with good input', ->
        orderText = 'A Province 1 Hold'
        order = new Hold(orderText, parse: true, provinces: provinces)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.unitType()).to.equal('A')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(orderText)

      describe 'with bad inputs,', ->
        describe 'not ending with Hold:', ->
          orderText = 'A Province 1 - Province 2'
          describe orderText, ->
            it "should raise syntax exception", ->
              expect(() -> new Hold(orderText, parse: true, provinces: provinces)).to.throw(Error)
              expect(() -> new Hold(orderText, parse: true)).to.throw(/Can't parse order text/)
        describe 'not starting with "A" or "F"', ->
          orderText = 'Province 1 Hold'
          describe orderText, ->
            it "should raise syntax exception", ->
              expect(() -> new Hold(orderText, parse: true, provinces: provinces)).to.throw(Error)
              expect(() -> new Hold(orderText, parse: true, provinces: provinces)).to.throw(/Can't parse order text/)
