var bootstrap = function() {
    var dipMap = new DipMap('#map'),
        historyBox = new HistoryBox('#messageBox'),
        collectOrders = null,
        defs = null,
        turnOrders = {}, state = null;

    function printCounts(state) {
        var counts = state.counts();
        for (pow in counts) {
            // TODO(ccraciun): Multiple types of forces here.
            historyBox.putLine(pow + ' has ' + counts[pow].SCs + ' SCs, ' +
                    counts[pow].armies + ' armies, ' +
                    counts[pow].fleets + ' fleets.', pow);
        }
    }

    function showTime(state) {
        jQuery('#map_interface #status #date').text(
                state.date.year + ' ' +
                state.date.season + ' ' +
                state.date.phase);
    }

    function loadMap(defsUrl, mapSvgUrl) {
        console.log('deferring loadMap');
        var deferred = new jQuery.Deferred();
        // TODO(ccraciun): Support loading jDip map data..
        jQuery.getJSON(defsUrl)
            .done(function (data) {
                defs = data;
                dipMap.setDefs(data);
                console.log('done loadMap');
                deferred.resolve();
            })
            .fail(function(jqxhr, textStatus, error) {
                console.error(textStatus + ', ' + error)
                deferred.reject(jqxhr, textStatus, error);
            });
        dipMap.loadMapFromUrl(mapSvgUrl);
        return deferred.promise();
    }

    function setState(newState) {
        state = new State(newState);
        printCounts(state);
        showTime(state);
        dipMap.drawState(state);
        for (i in state.active) {
            pow = state.active[i];
            jQuery('<span class="separator"> | </span>').appendTo(jQuery('#menu #powers'));
            jQuery('<a href="#" class="menu-item power ' + pow.toLowerCase() + '"><span>' + pow + '</span></a>').appendTo(jQuery('#menu #powers'));
        };
    }

    function loadStateUrl(stateUrl) {
        console.log('deferring loadStateUrl');
        var deferred = new jQuery.Deferred();
        jQuery.getJSON(stateUrl)
            .done(function (newState) {
                setState(newState);
                console.log('done loadStateUrl');
                deferred.resolve();
            })
            .fail(function(jqxhr, textStatus, error) {
                console.error(textStatus + ', ' + error)
                deferred.reject(jqxhr, textStatus, error);
            });
        return deferred.promise();
    }

    $.when(loadMap('data/europe_standard_defs.json', 'images/europe_standard.svg'), loadStateUrl('data/europe_standard_start.json'))
        .then(function(){ new Menu(dipMap, state); } );
};

$().ready(bootstrap);
