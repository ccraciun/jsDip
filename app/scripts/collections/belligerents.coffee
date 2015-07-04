backbone = require 'backbone'
Models = {
  Belligerent: require '../models/bb/belligerent'
}

module.exports = class Belligerents extends backbone.Collection
  model: Models.Belligerent
