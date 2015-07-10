backbone = require 'backbone'
_ = require 'underscore'

module.exports = class Unit extends backbone.Model
  parse: (data, options) ->
    _(super).tap (attrs) =>
      attrs.province = options.provinces.get(attrs.province)
      throw "Bad data encountered." unless attrs.province
      attrs.province.set('unit', @)
