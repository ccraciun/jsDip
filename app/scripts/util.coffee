loadjscssfile = (filename, filetype) ->
  if filetype is "js" #if filename is a external JavaScript file
    # alert('called');
    fileref = document.createElement("script")
    fileref.setAttribute "type", "text/javascript"
    fileref.setAttribute "src", filename
  
  # alert('called');
  else if filetype is "css" #if filename is an external CSS file
    fileref = document.createElement("link")
    fileref.setAttribute "rel", "stylesheet"
    fileref.setAttribute "type", "text/css"
    fileref.setAttribute "href", filename
  document.getElementsByTagName("head")[0].appendChild fileref  unless typeof fileref is "undefined"
  return
jQueryAjaxErrorHandler = (jqxhr, textStatus, error) ->
  
  # TODO(ccraciun): Append error to message/status window.
  err = textStatus + ", " + error
  console.error ": " + err
  return

# TODO(rkofman): Kill this with fire.
Function::partial = ->
  method = this
  args = Array::slice.call(arguments)
  ->
    method.apply this, args.concat(Array::slice.call(arguments))
