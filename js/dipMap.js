function Order(str, defs) {
    // self.unit - Element of unit for the order -- not guaranteed to be present.
    // self.pow - Power controlling the unit ordered.
    // self.org - Location of unit receiving order.
    // self.type - Type of unit (army/fleet).
    // self.act - Action being performed by unit from {build, hold, move, support, cargo}.
    // self.src - For convoy or support, location of unit that's being assisted.
    // self.dst - Destination of order.
    var self = this;

    this.toStr = function () {
        prefix = self.type + ' ' + self.org;
        if (self.act === 'hold' || self.act === 'build') {
            return prefix + ' ' + self.act;
        } else if (self.act == 'move') {
            return prefix + ' move ' + self.dst;
        } else {
            return prefix + ' ' + self.act + ' ' + self.src + ' ' + self.dst;
        };
    };

    this.finish = function () {
        // If we don't have a source unit, give up.
        if (!self.org) {
            return false;
        };
        // Try to guess source and destination based on action.
        if (self.act === 'hold') {
            self.src = self.dst = self.org;
        } else if (self.act === 'move' && self.src !== self.org) {
            self.dst = self.src;
        };
        // If we still have gaps, give up.
        if (!self.org || !self.src || !self.dst ||
                !self.pow || !self.type) {
            return false;
        };
        // Try to guess action from source and destination.
        if (!self.act) {
            if (self.dst === self.src &&
                    self.src === self.org) {
                self.act = 'hold';
            } else if (self.dst === self.src ||
                    self.src === self.org) {
                self.act = 'move';
                self.src = self.org;
            } else {
                // Either support or convoy.
                return false;
            };
        };
        return true;
    };

    function fromString(str, defs) {
        params = str.split(' ');
        var type = params[0],
            org = param[1],
            act = param[2],
            loc1 = param[3],
            loc2 = param[4];

        // TODO(ccraciun): Order sanity checks.
        if (!(type in defs.force_types)) {
            return null;
        };
        if (!(org in defs.alias)) {
            return null;
        };
        org = defs.alias[org];
        if (!(loc1 in defs.alias)) {
            return null;
        };
        src = defs.alias[loc1];
        if (!(loc2 in defs.alias)) {
            return null;
        };
        dst = defs.alias[loc2];
        if (!(act in ['hold', 'move', 'support', 'convoy', 'build'])) {
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
        map.append(rawMap.select('defs'));
        map.append(rawMap.select('g#MapLayer'));
        map.group().attr({'id': 'ForcesLayer', 'class': 'layer'});
        map.group().attr({'id': 'OrdersLayer', 'class': 'layer'});
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

    function drawItem(power, type, loc, layerSel) {
        var layer = map.select('g#ForcesLayer');
        if (layerSel) {
            layer = map.select(layerSel);
        };
        var container = layer.select('g#' + power);
        if (!container) {
            container = layer.group().attr({id: power});
        }
        var it = map.select('defs ' + type);
        it.use().attr({'class': 'force'})
                .transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container)
                .data({loc: loc, type: type, power: power});
    };

    this.drawOrder = function (order, layerSel) {
        var src = order.src,
            act = order.act,
            dst = order.dst,
            org = order.org,
            pow = order.pow,
            type = order.type;
        var layer = map.select('g#OrdersLayer');
        if (layerSel) {
            layer = map.select(layerSel);
        };
        var container = layer.select('g#' + pow);
        if (!container) {
            container = layer.group().attr({id: pow});
        };

        if (act === 'build') {
            drawItem(pow, type, org, cont);
        } else if (act === 'support' || act === 'convoy') {
            container.path('M' + defs.coords[org] + ' ' +
                           'Q' + defs.coords[src] + ' ' + defs.coords[dst])
                       .attr({'class': 'order ' + pow + ' ' + act});
        } else {
            container.path('M' + defs.coords[org] + ' ' +
                           'L' + defs.coords[dst])
                       .attr({'class': 'order ' + pow + ' ' + act});
        };
    };

    this.drawState = function (state) {
        // Draw SCs.
        for (sc in state.SC) {
            map.select('#sc' + sc).node.setAttribute('class', state.SC[sc]);
        };

        // Update forces
        var forces = map.select('g#ForcesLayer');
        forces.selectAll('g').remove();
        for (power in state.forces) {
            forces = state.forces[power];
            forces.armies.forEach(function (org) {
                drawItem(power, '#A', org);
            });
            forces.fleets.forEach(function (org) {
                drawItem(power, '#F', org);
            });
        };
    };

    this.clearOrders = function () {
        var ordersLayer = map.select('g#OrdersLayer');
        ordersLayer.selectAll('.order').remove();
        ordersLayer.selectAll('.force').remove();
    };

    this.drawOrders = function (orders) {
        this.clearOrders();
        for (it in orders) {
            order = orders[it];
            this.drawOrder(order, 'g#OrdersLayer');
        };
    };

    this.listenOrders = function (power, state) {
        var orders = {};

        function deselectActions() {
            jQuery('#map_interface .action.selected').removeClass('selected');
        };

        function selectAction(act) {
            deselectActions();
            jQuery('#map_interface .action.' + act.toLowerCase()).addClass('selected');
        };

        function selectedAction(pow) {
            sel = jQuery('#map_interface .action.selected')[0];
            if (sel) {
                return sel.text
            };
        };

        var highlightActions = function () {
            jQuery('#map_interface #actions .action').addClass('highlight');
        };

        var unhighlightActions = function () {
            jQuery('#map_interface #actions .action').removeClass('highlight');
        };

        var highlightResupply = function () {
            jQuery('#map_interface #adjustments .resupply').addClass('highlight');
        };

        var unhighlightResupply = function () {
            jQuery('#map_interface #adjustments .resupply').removeClass('highlight');
        };

        var highlightDisband = function () {
            jQuery('#map_interface #adjustments .disband').addClass('highlight');
        };

        var unhighlightDisband = function () {
            jQuery('#map_interface #adjustments .disband').removeClass('highlight');
        };

        var stopListen = function () {
            // TODO(ccraciun): Should specify which handlers we're removing
            // for better manners.
            map.selectAll('g#ForcesLayer #' + power + ' .force')
               .forEach(function (e) {
                   e.unclick();
            });
            map.selectAll('g#MapLayer .l').forEach(function (e) {
                e.unclick();
            });
            map.selectAll('g#MapLayer .w').forEach(function (e) {
                e.unclick();
            });
            jQuery('#map_interface #actions .action').unbind('click');
            jQuery('#map_interface #adjustments .resupply').unbind('click');
            jQuery('#map_interface #adjustments .action').unbind('click');

            map.selectAll('g#ForcesLayer .force.selected')
                    .forEach(function (sel) {
                sel.node.classList.remove('selected');
            });

            instanceDipMap.clearOrders();
            deselectActions();
            unhighlightActions();

            map.selectAll('.layer').forEach(function (layer) {
                layer.node.classList.remove('accepting');
            });
        };

        function listenMovementOrders(power) {
            var currentOrder = new Order();

            var finalizeOrder = function () {
                orders[currentOrder.org] = currentOrder;

                instanceDipMap.drawOrders(orders);
                currentOrder.unit.node.classList.remove('selected');
                currentOrder = new Order();
                deselectActions();
            };

            var forceClick = function (evt) {
                if (currentOrder.unit) {
                    currentOrder.unit.node.classList.remove('selected');
                }
                this.node.classList.add('selected');
                currentOrder.unit = this;
                currentOrder.type = this.data('type')
                currentOrder.org = this.data('loc');
                currentOrder.pow = this.data('power');
                currentOrder.src = null;
                currentOrder.dst = null;
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var regionClick = function (evt) {
                tgt = evt.target.parentNode.id;
                if (!currentOrder.unit) {
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
                        highlightActions();
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

            // Add listeners to the forces of given power.
            map.selectAll('g#ForcesLayer #' + power + ' .force')
               .forEach(function (e) {
                   e.click(forceClick);
            });
            map.selectAll('g#MapLayer .l').forEach(function (e) {
                e.click(regionClick);
            });
            map.selectAll('g#MapLayer .w').forEach(function (e) {
                e.click(regionClick);
            });
            jQuery('#map_interface #actions .action').click(actionClick);
            // TODO(ccraciun): Narrow accepting to only valid forces, and
            // territories when in retreat/resupply mode.
            map.select('#MapLayer').node.classList.add('accepting');
            map.select('#ForcesLayer').node.classList.add('accepting');

            return function () {
                stopListen();
                return orders;
            };
        };

        function listenAdjustmentOrders(power, adjustment) {
            var currentOrder = new Order();

            var finalizeOrder = function () {
                orders[currentOrder.org] = currentOrder;

                instanceDipMap.drawOrders(orders);
                currentOrder = new Order();
                unhighlightResupply();
            };

            var regionClick = function (evt) {
                tgt = evt.target.parentNode.id;
                currentOrder.org = tgt;
                if (currentOrder.finish()) {
                    finalizeOrder();
                } else {
                    highlightResupply();
                };
            };

            var resupplyClick = function (evt) {
                currentOrder.act = evt.target.textContent.toLowerCase();
                unhighlightActions();
                selectAction(currentOrder.act);
                if (currentOrder.finish()) {
                    finalizeOrder();
                };
            };

            var disbandClick = function (evt) {
            };

            map.selectAll('g#MapLayer .l').forEach(function (e) {
                e.click(regionClick);
            });
            map.selectAll('g#MapLayer .w').forEach(function (e) {
                e.click(regionClick);
            });
            if (adjustment > 0) {
                jQuery('#map_interface #adjustments .resupply').click(resupplyClick);
            } else {
                jQuery('#map_interface #adjustments .disband').click(disbandClick);
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
            var counts = state.counts[power],
                adjustment = counts.SCs - counts.armies - counts.fleets;
            return listenAdjustmentOrders(power, adjustment);
        };
    };
};
