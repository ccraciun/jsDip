function StatusBox(statusBoxSelector) {
    var statusBox = jQuery(statusBoxSelector);

    this.putLine = function (source, text) {
        jQuery('<div/>', {
            'class': 'message ' + source,
            text: text
        }.appendTo(statusBox);
    };
};
