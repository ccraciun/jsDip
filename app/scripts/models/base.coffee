root = exports ? this

root.BaseModel = class BaseModel
  modelMust: []
  modelMay: []

  constructor: (data) ->
    for key in @modelMust
      @[key] = data[key]

    for key, val of data when val? and key in @modelMay
      @[key] = val
