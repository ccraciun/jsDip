Base = require('./base')
template = require('../templates/header.hbs')

module.exports = class Header extends Base
  el: '#header'
  template: template


  toJSON: ->
    {
      season: "Fall"
      year: "1900"
      phase: "Order Phase"
      countries: [
        "Russia"
        "USA"
        "Israel"
      ]
    }
