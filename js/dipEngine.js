$(function () {
    var dipMap = new DipMap('#map'),
        statusBox = new StatusBox('#messageBox'),
        collectOrders = null,
        defs = null,
        turnOrders = {}, state = null;

    function updateCounts(state) {
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

        state.counts = counts;
        return counts;
    };

    function printCounts(state) {
        var counts = state.counts;
        for (pow in counts) {
            statusBox.putLine(pow + ' has ' + counts[pow].SCs + ' SCs, ' +
                    counts[pow].armies + ' armies, ' +
                    counts[pow].fleets + ' fleets.', pow);
        };
    };

    function showTurn(state) {
        jQuery('#map_interface #status #turn').text(
                state.turn.year + ' ' +
                state.turn.season + ' ' +
                state.turn.phase);
    };

    function loadMap(defsUrl, mapSvg, mapCss) {
        console.log('deferring loadMap');
        var deferred = new jQuery.Deferred();
        // TODO(ccraciun): Support loading jDip map data..
        jQuery.getJSON('data/europe_standard_defs.json')
            .done(function (data) {
                defs = data;
                dipMap.setDefs(data);
                console.log('done loadMap');
                deferred.resolve();
            })
            .fail(function(jqxhr, textStatus, error) {
                jQueryAjaxErrorHandler(jqxhr, textStatus, error);
                deferred.reject(jqxhr, textStatus, error);
            });
        dipMap.loadMapFromUrl('img/europe_standard.svg');
        loadjscssfile('css/europe_standard.css', 'css');
        return deferred.promise();
    }

    function setState(state) {
        updateCounts(state);
        printCounts(state);
        showTurn(state);
        dipMap.setState(state);
        for (i in state.active) {
            pow = state.active[i];
            jQuery('<span class="separator"> | </span>').appendTo(jQuery('#menu #powers'));
            jQuery('<a href="#" class="menu-item power ' + pow.toLowerCase() + '"><span>' + pow + '</span></a>').appendTo(jQuery('#menu #powers'));
        };
    };

    function loadStateUrl(stateUrl) {
        console.log('deferring loadStateUrl');
        var deferred = new jQuery.Deferred();
        jQuery.getJSON('data/europe_standard_start.json')
            .done(function (state) {
                setState(state);
                console.log('done loadStateUrl');
                deferred.resolve();
            })
            .fail(function(jqxhr, textStatus, error) {
                jQueryAjaxErrorHandler(jqxhr, textStatus, error);
                deferred.reject(jqxhr, textStatus, error);
            });
        return deferred.promise();
    };

    function deselectPowers() {
        jQuery('#menu .menu-item.selected').removeClass('selected');
    };

    function selectPower(pow) {
        deselectPowers();
        jQuery('#menu .menu-item.' + pow.toLowerCase()).addClass('selected');
    };

    function selectedPower(pow) {
        sel = jQuery('#menu .menu-item.selected')[0];
        if (sel) {
            return sel.textContent;
        };
    };

    function clickPower(evt) {
        if (collectOrders) {
            turnOrders[selectedPower] = collectOrders();
        };
        collectOrders = dipMap.listenOrders(evt.target.textContent);
        selectPower(evt.target.textContent);
    };

    function clickDone(evt) {
        if (collectOrders) {
            turnOrders[selectedPower] = collectOrders();
        };
        collectOrders = null;
        deselectPowers();
        state.orders = turnOrders;
    };

    function clickEndPhase(evt) {
        for (pow in state.active) {
        }
    };

    function menuListen() {
        console.log('menuListen');
        jQuery('#menu .menu-item.power').click(clickPower);
        jQuery('#menu .menu-item.done').click(clickDone);
        jQuery('#menu .menu-item.end-phase').click(clickEndPhase);
    };

    jQuery.when(loadMap('data/europe_standard_defs.json', 'img/europe_standard.svg', 'css/europe_standard_defs'), loadStateUrl('data/europe_standard_start.json'))
            .then(menuListen);
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
