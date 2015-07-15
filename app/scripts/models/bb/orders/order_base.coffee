backbone = require 'backbone'
_ = require 'underscore'

module.exports = class OrderBase extends backbone.Model
  parse: (data, options) ->
    super # TODO(rkofman): Write order-string parser.
