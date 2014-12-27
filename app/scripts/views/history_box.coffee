$ = window.$

class window.HistoryBox
  constructor: (selector) ->
    @$el = $(selector)

  putLine: (text, source='') ->
    @$el.add('div', class: 'message #{source}', text: text)
