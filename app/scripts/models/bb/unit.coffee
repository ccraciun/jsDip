backbone = require 'backbone'
_ = require 'underscore'

module.exports = class Unit extends backbone.Model
  # Expected attributes:
  #   type: 'fleet' / 'army'
  #   province: vivified Province model
  #   owner: vivified Country model
