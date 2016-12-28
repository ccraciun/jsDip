expect = require('chai').expect
Backbone = require('backbone')
Models = {
  Orders: require('../../../app/scripts/models/bb/orders')
  Province: require('../../../app/scripts/models/bb/province')
}

Hold = Models.Orders.Hold; # less repetitive text entry

describe 'Models.Orders.OrderParser', ->
  describe 'with a collection of Provinces to parse against', ->
    province1 = new Models.Province({name: 'Province 1'})
    province2 = new Models.Province({name: 'Province 2'})
    province3 = new Models.Province({name: 'Province 3'})
    provinces = new Backbone.Collection([province1, province2, province3], model: Models.Province)
    describe '#parse', ->
      parser = Models.Orders.getParser(provinces)
      describe 'of Hold order', ->
        text = 'A Province 1 Hold'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.unitType()).to.equal('A')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)
      describe 'of Move order', ->
        text = 'A Province 1 -> Province 2'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.unitType()).to.equal('A')
          expect(order.targetProvinceName()).to.equal('Province 2')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)
      describe 'of Disband order', ->
        text = 'Disband F Province 1'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.unitType()).to.equal('F')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)

      describe 'of Build order', ->
        text = 'Build F Province 2'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 2')
          expect(order.unitType()).to.equal('F')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)

      describe 'of Support-move order', ->
        text = 'F Province 1 Supports A Province 2 -> Province 3'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.sourceProvinceName()).to.equal('Province 2')
          expect(order.targetProvinceName()).to.equal('Province 3')
          expect(order.unitType()).to.equal('F')

        it "should successfully parse sub-order", ->
          suborder = order.get('subOrder')
          expect(suborder.provinceName()).to.equal('Province 2')
          expect(suborder.type()).to.equal('move')
          expect(suborder.targetProvinceName()).to.equal('Province 3')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)

      describe 'of Support-hold order', ->
        text = 'F Province 1 Supports A Province 2 Hold'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.sourceProvinceName()).to.equal('Province 2')
          expect(order.unitType()).to.equal('F')

        it "should successfully parse sub-order", ->
          suborder = order.get('subOrder')
          expect(suborder.provinceName()).to.equal('Province 2')
          expect(suborder.type()).to.equal('hold')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)

      describe 'of Convoy order', ->
        text = 'F Province 1 Convoys A Province 2 -> Province 3'
        order = parser.parse(text)

        it "should successfully parse order", ->
          expect(order.provinceName()).to.equal('Province 1')
          expect(order.sourceProvinceName()).to.equal('Province 2')
          expect(order.targetProvinceName()).to.equal('Province 3')
          expect(order.unitType()).to.equal('F')

        it "should successfully parse sub-order", ->
          suborder = order.get('subOrder')
          expect(suborder.provinceName()).to.equal('Province 2')
          expect(suborder.type()).to.equal('move')
          expect(suborder.targetProvinceName()).to.equal('Province 3')

        it "should successfully re-serialize the order", ->
          expect(order.toJSON()).to.equal(text)
