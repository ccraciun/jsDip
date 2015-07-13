backbone = require 'backbone'
_ = require 'underscore'

module.exports = class UnitBase extends backbone.Model
  parse: (data, options) ->
    _(super).tap (attrs) =>
      attrs.owner = options.owner
      attrs.province = options.allProvinces.get(attrs.province)
      throw "Bad data encountered." unless attrs.province
      attrs.province.set('unit', @)
