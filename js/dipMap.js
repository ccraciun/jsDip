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

    this.loadDefs = function (defsIn) {
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

    this.listenOrders = function (power, toggle) {
        var orders = {}, currentOrder = {};
        // Add listeners to the forces of given power.
        map.selectAll('g#ForcesLayer #' + power + ' .force')
           .forEach(function (e) {
               e.click(function (evt) {
                   this.node.classList.add('selected');
                   currentOrder.unit = this;
                   currentOrder.org = this.data('loc');
                   currentOrder.pow = this.data('power');
               })
        });

        var regionClick = function (evt) {
            tgt = evt.target.parentNode.id;
            if (!currentOrder.unit) {
                return;
            };
            if (!currentOrder.src) {
                currentOrder.src = tgt;
            } else if (!currentOrder.dst) {
                currentOrder.dst = tgt;
                if (currentOrder.dst === currentOrder.src &&
                        currentOrder.src === currentOrder.org) {
                    currentOrder.act = 'hold';
                } else if (currentOrder.dst === currentOrder.src ||
                        currentOrder.src === currentOrder.org) {
                    currentOrder.act = 'move';
                    currentOrder.src = currentOrder.org;
                } else {
                    currentOrder.act = 'support';
                }

                orders[currentOrder.unit] = currentOrder;
                console.log(orders);
                instanceDipMap.clearOrders();
                instanceDipMap.drawOrders(orders);
                currentOrder.unit.node.classList.remove('selected');
                currentOrder = {};
            };
        };

        map.selectAll('g#MapLayer .l').forEach(function (e) {
            e.click(regionClick);
        });
        map.selectAll('g#MapLayer .w').forEach(function (e) {
            e.click(regionClick);
        });

        return function () {
            return orders;
        };
    };
};
