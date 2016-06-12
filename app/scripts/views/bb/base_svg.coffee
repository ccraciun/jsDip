Views = {
  Base: require './base'
}
_ = require 'underscore'
$ = require 'jquery'

module.exports = class BaseSvgView extends Views.Base
  nameSpace: "http://www.w3.org/2000/svg"
  xlinkNameSpace: "http://www.w3.org/1999/xlink"

  _ensureElement: ->
    if !@el
      attrs = _.extend({}, _.result(@, 'attributes'));
      attrs.id = _.result(@, 'id') if @id
      attrs['class'] = _.result(@, 'className') if @className
      $el = $(window.document.createElementNS(_.result(@, 'nameSpace'), _.result(@, 'tagName'))).attr(attrs)
      @_setXlinkAttrs($el)
      @setElement($el, false);
    else
      @setElement(_.result(@, 'el'), false)

  _setXlinkAttrs: ($el) ->
    for key, value of _.result(@, 'xlink')
      debugger unless $el
      $el[0].setAttributeNS(@xlinkNameSpace, key, value)

