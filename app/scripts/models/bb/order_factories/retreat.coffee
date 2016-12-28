BaseOrdersFactory = require './base'

Models = {
  Orders: {
    Move: require '../orders/move'
    Disband: require '../orders/disband'
  }
}

module.exports = class RetreatOrdersFactory extends BaseOrdersFactory
  actionableProvinces: ->
    @get('country').get('units').where(disloged: true).map (unit) ->
      unit.get('province')
