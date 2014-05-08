function State (info) {
    var self = this,
        _counts = null;

    this.counts = function () {
        if (!_counts) {
            _counts = {};

            for (power in self.SCs) {
                _counts[power] = _counts[power] || {};
                _counts[power].SCs = self.SCs[power].length;
            };

            for (power in self.forces) {
                _counts[power] = _counts[power] || {};
                _counts[power].armies = self.forces[power].armies.length;
                _counts[power].fleets = self.forces[power].fleets.length;
                _counts[power].forces = _counts[power].armies +
                                        _counts[power].fleets;
                _counts[power].adjustment = _counts[power].SCs -
                                            _counts[power].forces;
            };
        };
        return _counts;
    };

    this.forceAt = function (loc) {
        for (power in self.forces) {
            for (type in self.forces[power]) {
                if (loc in self.forces[power][type]) {
                    return {power: power, type: type};
                };
            };
        };
        return null;
    };

    jQuery.extend(this, info);

    self.SC = {};
    _(self.SCs).each(function (scList, power) {
        _(scList).each(function (loc) {
            if (self.SC[loc]) {
                console.error(loc + " is claimed by " + this.SC[loc] + " and " 
                        + power);
                return null;
            };
            self.SC[loc] = power;
        });
    });
};

$(function () {
    var dipMap = new DipMap('#map'),
        statusBox = new StatusBox('#messageBox'),
        collectOrders = null,
        defs = null,
        turnOrders = {}, state = null;

    function printCounts(state) {
        var counts = state.counts();
        for (pow in counts) {
            // TODO(ccraciun): Multiple types of forces here.
            statusBox.putLine(pow + ' has ' + counts[pow].SCs + ' SCs, ' +
                    counts[pow].armies + ' armies, ' +
                    counts[pow].fleets + ' fleets.', pow);
        };
    };

    function printOrders(orders) {
        console.log('Current turn orders:');
        for (pow in turnOrders) {
            console.log('For ' + pow);
            for (idx in turnOrders[pow]) {
                console.log(turnOrders[pow][idx].toStr());
            };
        };
        console.log(turnOrders);
    };

    function showTime(state) {
        jQuery('#map_interface #status #date').text(
                state.date.year + ' ' +
                state.date.season + ' ' +
                state.date.phase);
    };

    function loadMap(defsUrl, mapSvgUrl, mapCssUrl) {
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
                jQueryAjaxErrorHandler(jqxhr, textStatus, error);
                deferred.reject(jqxhr, textStatus, error);
            });
        dipMap.loadMapFromUrl(mapSvgUrl);
        loadjscssfile(mapCssUrl, 'css');
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
    };

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

    function selectedPower() {
        sel = jQuery('#menu .menu-item.selected')[0];
        if (sel) {
            return sel.textContent;
        };
    };

    function clickPower(evt) {
        if (collectOrders) {
            turnOrders[selectedPower()] = collectOrders();
        };
        collectOrders = dipMap.listenOrders(evt.target.textContent, state);
        selectPower(evt.target.textContent);
    };

    function clickDone(evt) {
        if (collectOrders) {
            turnOrders[selectedPower()] = collectOrders();
        };
        collectOrders = null;
        deselectPowers();
        printOrders(turnOrders);
    };

    function clickEndPhase(evt) {
        clickDone();
        for (idx in state.active) {
            pow = state.active[idx];
            if (!(pow in turnOrders)) {
                console.log(pow + ' is active but has no orders.');
            };
        };
        // WIP(ccraciun): Stuff here.
        newState = judge(state, turnOrders);
        console.log(newState);
    };

    function listenMenu() {
        console.log('listenMenu');
        jQuery('#menu .menu-item.power').click(clickPower);
        jQuery('#menu .menu-item.done').click(clickDone);
        jQuery('#menu .menu-item.end-phase').click(clickEndPhase);
    };

    jQuery.when(loadMap('data/europe_standard_defs.json', 'img/europe_standard.svg', 'css/europe_standard.css'), loadStateUrl('data/europe_standard_start.json'))
            .then(listenMenu);
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
