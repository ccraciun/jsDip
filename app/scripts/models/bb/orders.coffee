_ = require('underscore')
Models = {
  Orders: {
    Build: require('./orders/build')
    Convoy: require('./orders/convoy')
    Disband: require('./orders/disband')
    Hold: require('./orders/hold')
    Move: require('./orders/move')
    Support: require('./orders/support')
  }
}
# orderMatchers = {
#   'hold': /([AF]) (.+) HOLD/ # /(army/fleet) (province)/
# }

orderAliasesMap = {
  Build: ['build', 'builds']
  Disband: ['disband', 'disbands']
  Hold: ['hold', 'holds']
  Move: ['move', 'moves', '-', '->'] # Note: doubles as retreat order.
  Support: ['support', 'supports']
  Convoy: ['convoy', 'convoys']
}

allOrderAliases = _.chain(orderAliasesMap).values().flatten().value()

class OrderParser
  constructor: (provinces) ->
    @provinces = provinces

  parse: (orderText) ->
    orderName = @parseOrderName(orderText)
    new Models.Orders[orderName](orderText, provinces: @provinces, parse: true, orderParser: @)

  parseOrderName: (orderText) ->
    orderAliasesForRegex = allOrderAliases.join('|')
    orderRegex = new RegExp("^.*?(#{orderAliasesForRegex})", 'i')
    match = orderText.match(orderRegex)
    orderAlias = match[1]
    orderName = @canonicalOrderName(orderAlias)

  canonicalOrderName: (orderAlias) ->
    orderAlias = orderAlias.toLowerCase()
    _(orderAliasesMap).findKey (values) ->
      _(values).contains(orderAlias)


getParser = (provinces) ->
  return new OrderParser(provinces)

module.exports = {
  getParser: getParser
}
