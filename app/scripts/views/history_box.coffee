$ = window.$

module.exports = class HistoryBox
  constructor: (selector) ->
    @$el = $(selector)

  putLine: (text, source='') ->
    @$el.append("<div class='message #{source}'>#{text}</div>")
