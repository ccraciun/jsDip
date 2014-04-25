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

    this.placeItem = function (container, type, loc) {
        var it = map.select('defs ' + type);
        it.use().attr({'class': 'force'})
                .transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container);
    };

    this.placeItem2 = function (power, type, loc) {
        var forces = map.select('g#ForcesLayer');
        var power = forces.select('g#' + power);
        if (!power) {
            power = forces.group().attr({id: power});
        }
        var it = map.select('defs ' + type);
        it.use().attr({'class': 'force'})
                .data({loc: loc, type: type, power: power})
                .transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container);
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
            gPow = forces.group().attr({id: power});
            state.forces[power].armies.map(
                this.placeItem.partial(gPow, '#A'));
            state.forces[power].fleets.map(
                this.placeItem.partial(gPow, '#F'));
        };
    };

    this.drawOrders = function (orders) {
        var ordersLayer = map.select('g#OrdersLayer');
        for (unit in orders) {
            var unit = orders[unit].unit,
                src = orders[unit].src,
                act = orders[unit].act,
                dst1 = orders[unit].dst1,
                dst2 = orders[unit].dst2,
                pow = orders[unit].pow;
            // TODO(ccraciun): Handle orders other than move.
            if (act == 'move') {
                ordersLayer.path('M' + defs.coords[src] + 'L' + defs.coords[dst1])
                           .attr({'marker-end': 'url(#head_success)',
                                  'class': 'order ' + pow});
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
                   console.log('Got a click on ' + evt.target);
                   currentOrder.unit = evt.target;
               })
        });
        // Add listeners to the territories.
        var regionClick = function (evt) {
            console.log('Got a click on ' + evt.target);
            tgt = evt.target.parentNode.id;
            if (!currentOrder.unit) {
                return;
            };
            if (!currentOrder.src) {
                currentOrder.src = tgt;
            } else if (!currentOrder.dst1) {
                currentOrder.dst1 = tgt;
            } else if (!currentOrder.dst2) {
                currentOrder.dst2 = tgt;
                currentOrder.act = 'move';
                orders[currentOrder.unit] = currentOrder;
                console.log(orders);
                instanceDipMap.clearOrders();
                instanceDipMap.drawOrders(orders);
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
