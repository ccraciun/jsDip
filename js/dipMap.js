function DipMap(mapSelector) {
    // The map frontend
    // TODO(ccraciun): patch Snap to support loading defs.
    var map = Snap(mapSelector);
    var defs = null;

    this.getMap = function () { return map };

    function onLoadRawSvg(rawMap) {
        map.append(rawMap.select('defs'));
        map.append(rawMap.select('g#MapLayer'));
        map.group().attr({
            id: 'ForcesLayer'
        });
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
        it.use().transform('translate(' + defs.coords[loc] + ')')
                .appendTo(container);
    };

    this.setState = function (state) {
        // TODO(ccraciun): Move counting into separate function.
        var counts = {}
        defs.belligerents.map(function(pow) {
            counts[pow] = {
                SCs: 0,
                armies: 0,
                fleets: 0
            }
        });

        // Update SC state.
        for (sc in state.SC) {
            map.select('#sc' + sc).node.setAttribute('class', state.SC[sc]);
            if(state.SC[sc] in counts) {
                counts[state.SC[sc]].SCs++;
            }
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

            counts[power].armies = state.forces[power].armies.length;
            counts[power].fleets = state.forces[power].fleets.length;
        };

        // Update status bar.
        for (pow in counts) {
            console.log('Power ' + pow + ' has ' + counts[pow].SCs + ' SCs, ' +
                    counts[pow].armies + ' armies, ' +
                    counts[pow].fleets + ' fleets.');
        };
    };
};
