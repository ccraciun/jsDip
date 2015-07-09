Views = {
  Base: require './base'
}
_ = require 'underscore'
$ = require 'jQuery'

module.exports = class BaseSvgView extends Views.Base
  nameSpace: "http://www.w3.org/2000/svg",
  _ensureElement: ->
    if !@el
      attrs = _.extend({}, _.result(this, 'attributes'));
      attrs.id = _.result(this, 'id') if @id
      attrs['class'] = _.result(this, 'className') if @className
      $el = $(window.document.createElementNS(_.result(@, 'nameSpace'), _.result(@, 'tagName'))).attr(attrs);
      @setElement($el, false);
    else
      @setElement(_.result(@, 'el'), false)
