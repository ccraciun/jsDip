BaseOrdersFactory = require './base'

Models = {
  Orders: {
    Retreat: require '../orders/retreat'
    Disband: require '../orders/disband'
  }
}

module.exports = class RetreatOrdersFactory extends BaseOrdersFactory
  actionableProvinces: ->
    @get('country').get('units').where(disloged: true).map (unit) ->
      unit.get('province')
