$(function () {
    var map = new DipMap('#map');
    var statusBox = new StatusBox('#messageBox');

    function countStatus(state) {
        var counts = {};

        // Update SC state.
        for (sc in state.SC) {
            if (!(state.SC[sc] in counts)) {
                counts[state.SC[sc]] = {
                    SCs: 0,
                    armies: 0,
                    fleets: 0
                }
            }
            counts[state.SC[sc]].SCs++;
        };

        for (power in state.forces) {
            counts[power].armies = state.forces[power].armies.length;
            counts[power].fleets = state.forces[power].fleets.length;
        };

        // Update status bar.
        for (pow in counts) {
            statusBox.putLine(pow + ' has ' + counts[pow].SCs + ' SCs, ' +
                    counts[pow].armies + ' armies, ' +
                    counts[pow].fleets + ' fleets.', pow);
        };

        return counts;
    };

    // TODO(ccraciun): Ideally we would use jDip map data.
    jQuery.getJSON('data/europe_standard_defs.json')
        .done(function (data) {
            map.loadDefs(data);
        })
        .fail(jQueryAjaxErrorHandler);

    map.loadMapFromUrl('img/europe_standard.svg');
    loadjscssfile('css/europe_standard.css', 'css');
    jQuery.getJSON('data/europe_standard_start.json')
        .done(function (data) {
            // TODO(ccraciun): We need defs to be loaded before this is called,
            // but this is not enforced.
            map.setState(data);
            countStatus(data);
            map.listenOrders('Austria');
        })
        .fail(jQueryAjaxErrorHandler);
});

// TODO(ccraciun): Rename to history box.
function StatusBox(statusBoxSelector) {
    var statusBox = jQuery(statusBoxSelector);

    this.putLine = function (text, source) {
        if (!source) {
            source = '';
        }
        jQuery('<div/>', {
            'class': 'message ' + source,
            text: text
        }).appendTo(statusBox);
    };
};
