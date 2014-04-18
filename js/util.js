function loadjscssfile(filename, filetype) {
    if (filetype == "js") { //if filename is a external JavaScript file
        // alert('called');
        var fileref = document.createElement('script')
            fileref.setAttribute("type", "text/javascript")
            fileref.setAttribute("src", filename)
            // alert('called');
    }
    else if (filetype == "css") { //if filename is an external CSS file
        var fileref = document.createElement("link")
            fileref.setAttribute("rel", "stylesheet")
            fileref.setAttribute("type", "text/css")
            fileref.setAttribute("href", filename)
    }
    if (typeof fileref != "undefined")
        document.getElementsByTagName("head")[0].appendChild(fileref)
};

function jQueryAjaxErrorHandler(jqxhr, textStatus, error) {
    // TODO(ccraciun): Append error to message/status window.
    var err = textStatus + ", " + error;
    console.error(': ' + err);
};

Function.prototype.partial = function () {
    var method = this, args = Array.prototype.slice.call(arguments);
    return function () {
        return method.apply(this,
                args.concat(Array.prototype.slice.call(arguments)));
    }
}
