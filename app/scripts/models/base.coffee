root = exports ? this

_ = require 'underscore'

root.BaseModel = class BaseModel
  modelMust: []
  modelMay: []

  constructor: (data) ->
    for key in @modelMust
      @[key] = data[key]

    for key, val of data when val? and key in @modelMay
      @[key] = val

  matches: (rhs) ->
    for key, val of @
      unless key in @modelMust or key in @modelMay
        continue
      unless val
        continue
      if val?.matches
        if not val.matches rhs[key]
          return false
      else unless val == rhs[key]
        return false
    return true
