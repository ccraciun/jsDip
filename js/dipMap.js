function Order() {
    var self = this;

    this.toStr = function () {
        prefix = self.type + ' ' + self.org;
        if (self.act === 'hold') {
            return prefix + ' hold';
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
};

function DipMap(mapSelector) {
    // The map frontend
    // TODO(ccraciun): patch Snap to support loading defs.
    var map = Snap(mapSelector), defs = null, instanceDipMap = this;

    this.getMap = function () { return map };

    function onLoadRawSvg(rawMap) {
        map.append(rawMap.select('defs'));
        map.append(rawMap.select('g#MapLayer'));
        map.group().attr({id: 'ForcesLayer'});
        map.group().attr({id: 'OrdersLayer'});
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

    this.placeItem = function (power, type, loc) {
        var forces = map.select('g#ForcesLayer');
        var container = forces.select('g#' + power);
        if (!container) {
            container = forces.group().attr({id: power});
        }
        var it = map.select('defs ' + type);
        it.use().attr({'class': 'force'})
                .transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container)
                .data({loc: loc, type: type, power: power});
    };

    this.setState = function (state) {
        // Update SC state.
        for (sc in state.SC) {
            map.select('#sc' + sc).node.setAttribute('class', state.SC[sc]);
        };

        // Update forces
        var forces = map.select('g#ForcesLayer');
        forces.selectAll('g').remove();
        for (power in state.forces) {
            state.forces[power].armies.map(
                this.placeItem.partial(power, '#A'));
            state.forces[power].fleets.map(
                this.placeItem.partial(power, '#F'));
        };
    };

    this.drawOrders = function (orders) {
        var ordersLayer = map.select('g#OrdersLayer');
        this.clearOrders();
        for (unit in orders) {
            var src = orders[unit].src,
                act = orders[unit].act,
                dst = orders[unit].dst,
                org = orders[unit].org,
                pow = orders[unit].pow;
            // TODO(ccraciun): Handle orders other than move.
            if (act === 'support' || act === 'convoy') {
                ordersLayer.path('M' + defs.coords[org] + ' ' +
                                 'Q' + defs.coords[src] + ' ' + defs.coords[dst])
                           .attr({'class': 'order ' + pow + ' ' + act});
            } else {
                ordersLayer.path('M' + defs.coords[org] + ' ' +
                                 'L' + defs.coords[dst])
                           .attr({'class': 'order ' + pow + ' ' + act});
            };
        };
    };

    this.clearOrders = function () {
        var ordersLayer = map.select('g#OrdersLayer');
        ordersLayer.selectAll('.order').remove();
    };

    this.listenOrders = function (power) {
        var orders = {}, currentOrder = new Order();

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

        var finalizeOrder = function () {
            orders[currentOrder.unit] = currentOrder;

            instanceDipMap.drawOrders(orders);
            currentOrder.unit.node.classList.remove('selected');
            currentOrder = new Order();
            deselectActions();
        };

        var forceClick = function (evt) {
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

        var highlightActions = function () {
            jQuery('#map_interface #actions .action').addClass('highlight');
        };

        var unhighlightActions = function () {
            jQuery('#map_interface #actions .action').removeClass('highlight');
        };

        var stopListen = function () {
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
            jQuery('#map_interface #actions .action').click();

            if (currentOrder.unit) {
                currentOrder.unit.node.classList.remove('selected');
            }
            instanceDipMap.clearOrders();
            deselectActions();
            unhighlightActions();
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

        return function () {
            stopListen();
            return orders;
        };
    };
};
