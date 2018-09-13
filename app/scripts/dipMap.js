function Order(str, defs) {
    // self.unit - Element of unit for the order -- not guaranteed to be present.
    // self.pow - Power controlling the unit ordered.
    // self.org - Location of unit receiving order.
    // self.type - Type of unit (army/fleet).
    // self.act - Action being performed by unit from {build, hold, move, support, convoy}.
    // self.src - For convoy or support, location of unit that's being assisted.
    // self.dst - Destination of order.
    var self = this;

    this.toStr = function () {
        prefix = self.type + ' ' + self.org;
        if (self.act === 'hold' || self.act === 'build' || self.act === 'disband') {
            return prefix + ' ' + self.act;
        } else if (self.act == 'move') {
            return prefix + ' move ' + self.dst;
        } else {
            return prefix + ' ' + self.act + ' ' + self.src + ' -> ' + self.dst;
        };
    };

    this.finish = function () {
        // If we don't have a source unit, give up.
        if (!self.org || !self.type) {
            return false;
        };
        // Try to guess source and destination based on action.
        if (self.act in ['build', 'move', 'disband']) {
            return true;
        } else if (self.act === 'move') {
            if (self.src !== self.org) {
                // We can guess the destination.
                self.dst = self.src;
            };
            // Valid if we have a destination.
            return self.dst;
        } else if (self.act in ['support', 'convoy']) {
            // Valid if we have a source and destination.
            return self.src && self.dst;
        };
        // Try to guess action from source and destination.
        if (!self.act) {
            if (!self.src || !self.dst) {
                // Not enough to guess;
                return false;
            }
            if (self.dst === self.src &&
                    self.src === self.org) {
                self.act = 'hold';
            } else if (self.dst === self.src ||
                    self.src === self.org) {
                self.act = 'move';
                self.src = self.org;
            } else {
                // Either support or convoy, but we can't easily guess.
                return false;
            };
        };
        return true;
    };

    function fromStr(str, defs) {
        params = str.split(' ');
        var type = params[0] || null,
            org = param[1] || null,
            act = param[2] || null,
            loc1 = param[3] || null,
            loc2 = param[4] || null;

        // TODO(ccraciun): Parse more order phrases, add more order sanity checks.
        // type, origin and action are mandatory.
        if (type && !(type in defs.force_types)) {
            return null;
        };
        if (!(org = defs.alias[org])) {
            return null;
        };
        if (act) {
            act = act.toLowerCase();
        };
        if (!(act in ['hold', 'move', 'support', 'convoy', 'build', 'disband'])) {
            return null;
        };
        if (src && !(src = defs.alias[loc1])) {
            return null;
        };
        if (dst && !(dst = defs.alias[loc2])) {
            return null;
        };

        self.type = type;
        self.org = org;
        self.act = act;
        self.src = loc1;
        self.dst = loc2;
    };

    // build from string.
    if (str && defs) {
        fromString(str, defs);
    };
};

function DipMap(mapSelector) {
    // The map frontend.
    var map = Snap(mapSelector), defs = null, instanceDipMap = this;

    this.getMap = function () { return map };

    function onLoadRawSvg(rawMap) {
        map.clear();
        map.append(rawMap.select('defs'));
        map.append(rawMap.select('g#MapLayer'));
        map.group().attr({'id': 'ForcesLayer', 'class': 'layer'});
        map.group().attr({'id': 'SupplyCentersLayer', 'class': 'layer'});
        map.group().attr({'id': 'OrdersLayer', 'class': 'layer'});
        map.group().attr({'id': 'ResultsLayer', 'class': 'layer'});
    };

    this.loadMap = function (mapSvg) {
        onLoadRawSvg(Snap.parse(mapSvg));
    };

    this.loadMapFromUrl = function (mapUrl) {
        Snap.load(mapUrl, onLoadRawSvg);
    };

    this.setDefs = function (defsIn) {
        defs = defsIn;
    };

    function getPowerContainer(layer, power) {
        var container = layer.select('g.' + power);
        if (!container) {
            container = layer.group().attr({'class': power});
        }
        return container;
    };


    function drawForce(power, type, loc, container) {
        var it = map.select('defs #' + type);
        if (!container) {
            var layer = map.select('g#ForcesLayer'),
            container = getPowerContainer(layer, power);
        };
        it.use().attr({'class': 'force'})
                .transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container)
                .data({org: loc, type: type, power: power});
    };

    function drawSC(power, loc, layerSel) {
        var layer = map.select(layerSel || 'g#SupplyCentersLayer'),
            container = getPowerContainer(layer, power),
            it = map.select('defs #sc');
        it.use().attr({'class': 'sc ' + power + ' ' + loc})
                .transform('translate(' + defs.coords['sc' + loc] + ')')
                .appendTo(container)
                .data({org: loc, power: power});
    };

    function drawOrder(order, layerSel) {
        var src = order.src,
            act = order.act,
            dst = order.dst,
            org = order.org,
            pow = order.pow,
            type = order.type,
            result = order.result;

        var layer = map.select(layerSel || 'g#OrdersLayer'),
            container = getPowerContainer(layer, pow),
            it = null;

        if (act === 'build') {
            return drawForce(pow, type, org, container);
        };

        if (act === 'support' || act === 'convoy') {
            it = container.path('M' + defs.coords[org] + ' ' +
                           'Q' + defs.coords[src] + ' ' + defs.coords[dst])
                          .attr({'class': 'order ' + pow + ' ' + act});
        } else {
            it = container.path('M' + defs.coords[org] + ' ' +
                           'L' + defs.coords[dst])
                          .attr({'class': 'order ' + pow + ' ' + act});
        };
        it.data({org: org, power: pow, type: type, act: act, src: src, dst: dst});
    };

    this.drawState = function (state) {
        // Draw SCs.
        for (scLoc in state.SC) {
            drawSC(state.SC[scLoc], scLoc);
        };

        // Update forces
        var mapForces = map.select('g#ForcesLayer');
        if (mapForces) {
          mapForces.selectAll('g').remove();
        }
        for (unit of state.forces) {
            drawForce(unit.owner, unit.type, unit.loc)
        };
    };

    this.clearOrders = function () {
        map.select('g#OrdersLayer').clear();
    };

    this.drawOrders = function (orders) {
        this.clearOrders();
        for (it in orders) {
            order = orders[it];
            drawOrder(order, 'g#OrdersLayer');
        };
    };

    this.listenOrders = function (power, state) {
        var orders = {};

        function deselectActions() {
            jQuery('#map_actions .selected').removeClass('selected');
        };

        function selectAction(act) {
            deselectActions();
            jQuery('#map_actions .action.' + act.toLowerCase())
                    .addClass('selected');
        };

        function selectedAction() {
            sel = jQuery('#map_actions .action.selected')[0];
            return sel.text;
        };

        function highlightActions(actClass, actContainer) {
            actContainer = actContainer || 'map_actions';
            actClass = actClass || 'movement';
            jQuery('#' + actContainer + ' .' + actClass + '.action')
                    .addClass('highlight');
        };

        function unhighlightActions(actClass, actContainer) {
            actContainer = actContainer || 'map_actions';
            if (actClass) {
                jQuery('#' + actContainer + ' .' + actClass + '.action')
                        .removeClass('highlight');
            } else {
                jQuery('#' + actContainer + ' .action').removeClass('highlight');
            };
        };

        var stopListen = function () {
            // TODO(ccraciun): Should specify which handlers we're removing
            // for better manners.
            map.selectAll('g#ForcesLayer .' + power + ' .force')
               .forEach(function (e) {
                   e.unclick();
            });
            map.selectAll('g#MapLayer .l').forEach(function (e) {
                e.unclick();
            });
            map.selectAll('g#MapLayer .w').forEach(function (e) {
                e.unclick();
            });
            map.selectAll('g#SupplyCentersLayer .sc').forEach(function (e) {
                e.unclick();
            });
            jQuery('#map_interface #map_actions .action').unbind('click');
            jQuery('#map_interface #adjustments .resupply').unbind('click');
            jQuery('#map_interface #adjustments .action').unbind('click');

            map.selectAll('g#ForcesLayer .force.selected')
                    .forEach(function (sel) {
                sel.node.classList.remove('selected');
            });

            instanceDipMap.clearOrders();
            deselectActions();
            unhighlightActions();

            map.selectAll('.accepting').forEach(function (it) {
                it.node.classList.remove('accepting');
            });
        };

        function listenMovementOrders(power) {
            var currentOrder = new Order();

            var finalizeOrder = function () {
                var canonical = window.defs.canonicalName(currentOrder.org);
                orders[canonical] = currentOrder;

                instanceDipMap.drawOrders(orders);
                currentOrder.unit.node.classList.remove('selected');
                deselectActions();

                currentOrder = new Order();
            };

            var forceClick = function (evt) {
                if (currentOrder.unit) {
                    currentOrder.unit.node.classList.remove('selected');
                }
                this.node.classList.add('selected');
                currentOrder.unit = this;
                currentOrder.type = this.data('type')
                currentOrder.org = this.data('org');
                currentOrder.pow = this.data('power');
                currentOrder.src = null;
                currentOrder.dst = null;
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var regionClick = function (evt) {
                var tgt = evt.target.parentNode.id;
                if (!currentOrder.unit) {
                    // TODO(ccraciun): Set origin/get unit that lives at
                    // this point if available.
                    return;
                };
                if (!currentOrder.src) {
                    currentOrder.src = tgt;
                } else if (!currentOrder.dst) {
                    currentOrder.dst = tgt;
                    if (currentOrder.finish()) {
                        finalizeOrder();
                    } else {
                        // We don't know what action is wanted.
                        highlightActions('movement');
                    };
                };
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var actionClick = function (evt) {
                currentOrder.act = evt.target.textContent.toLowerCase();
                unhighlightActions();
                selectAction(currentOrder.act);
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            // TODO(ccraciun): Narrow accepting to only valid forces, and
            // territories when in retreat/resupply mode.
            map.selectAll('g#ForcesLayer .' + power + ' .force')
               .forEach(function (e) {
                   e.click(forceClick);
            });
            map.select('#ForcesLayer').node.classList.add('accepting');

            map.selectAll('g#MapLayer .l').forEach(function (e) {
                e.click(regionClick);
            });
            map.selectAll('g#MapLayer .w').forEach(function (e) {
                e.click(regionClick);
            });
            map.select('#MapLayer').node.classList.add('accepting');

            jQuery('#map_interface #map_actions .action').click(actionClick);

            return function () {
                stopListen();
                return orders;
            };
        };

        function listenAdjustmentOrders(power, adjustment) {
            // TODO(ccraciun): Disallow building in occupied non-home regions.
            // Disallow building fleets in non-coastal regions.
            var currentOrder = new Order();

            function finalizeOrder () {
                var canonical = defs.canonical(currentOrder.org);
                orders[canonical] = currentOrder;

                instanceDipMap.drawOrders(orders);
                if (currentOrder.sc) {
                    currentOrder.sc.node.classList.remove('selected');
                };
                unhighlightActions();
                deselectActions();

                currentOrder = new Order();
            };

            function forceClick (evt) {
                this.node.classList.add('selected');
                currentOrder.unit = this;
                currentOrder.type = this.data('type')
                currentOrder.org = this.data('org');
                currentOrder.pow = this.data('power');
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var regionClick = function (evt) {
                var tgt = evt.target.parentNode.id,
                    canonical = defs.canonical(tgt),
                    sc = map.select('#SupplyCentersLayer .' + canonical);
                sc.node.classList.add('selected');
                currentOrder.sc = sc;
                currentOrder.org = tgt;
                currentOrder.pow = sc.data('power');
                if (currentOrder.finish()) {
                    finalizeOrder();
                } else {
                    highlightActions('resupply');
                };
            };

            var resupplyClick = function (evt) {
                currentOrder.act = 'build';
                // TODO(ccraciun): Load/Set force types dynamically.
                type = evt.target.textContent.toLowerCase();
                currentOrder.type = {'army':'A', 'fleet':'F'}[type];
                selectAction(type);
                unhighlightActions('resupply');
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var disbandClick = function (evt) {
                currentOrder.act = 'disband';
                unhighlightDisband();
                selectAction(currentOrder.act);
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            if (adjustment > 0) {
                // Player may build.
                jQuery('#map_interface #adjustments .resupply')
                        .click(resupplyClick);

                _(defs.headquarters[power]).each(function (hq) {
                    if (state.SC[hq] === power) {
                        map.selectAll('g#MapLayer .' + hq)
                                .forEach(function (e) {
                            e.node.classList.add('accepting');
                            e.click(regionClick);
                        });
                    };
                });
            } else if (adjustment < 0) {
                // Player has to disband.
                jQuery('#map_interface #adjustments .disband')
                        .click(disbandClick);
                map.selectAll('g#ForcesLayer .' + power + ' .force')
                        .forEach(function (e) {
                    e.click(forceClick);
                });
                map.select('g#ForcesLayer .' + power)
                        .node.classList.add('accepting');
            } else {
                // Highlight "Done" button?
            };

            return function () {
                stopListen();
                return orders;
            };
        };

        function listenRetreatOrders(power) {
        };

        if (state.date.phase === 'Movement') {
            return listenMovementOrders(power);
        } else if (state.date.phase === 'Retreat') {
            return listenRetreatOrders(power);
        } else if (state.date.phase === 'Adjustment') {
            var counts = state.counts()[power],
                adjustment = counts.SCs - counts.armies - counts.fleets;
            return listenAdjustmentOrders(power, adjustment);
        };
    };
};
