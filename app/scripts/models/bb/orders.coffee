orderMatchers = {
  'hold': /([AF]) (.+) HOLD/ # /(army/fleet) (province)/
}

module.exports = {
  parse: (text) =>
    match = text.match(orderMatchers['hold'])
    throw new Error("Can't parse order text") unless match
}
