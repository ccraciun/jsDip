module.exports = {}
OrderBase = require './order_base'
module.exports = class HoldOrder extends OrderBase
  parse: (text) ->
    match = text.match(/([AF]) (.+) Hold/)
    throw new Error("Can't parse order text") unless match
    unitType = match[1]
    provinceName = match[2]


module.exports.type = "hold"
module.exports.displayName = "Hold"
