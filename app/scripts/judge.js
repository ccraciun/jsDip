// judge(state, orders) -> state.
// Here, state will have orders attached results [success, fail, standoff, retreat, disband].
function judge(state, orders, defs) {
    // Default seasons are:
    // Spring -> Autumn -> Winter (Adjustments)
    // Changeable by defs.
    // Phases are:
    // (Non-Adjustment Season) Movement -> Retreat/Disband
    // (Adjustment Season) Build/Disband
    var phases = ['Movement', 'Retreat'],
        seasons = defs.seasons,
        adj_seasons = defs.adjustment_seasons;

    var phaseJudge = {
        'Movement': judgeMovement,
        'Retreat': judgeRetreat,
        'Adjustment': judgeAdjustment
    };

    var prePhaseJudge = {
        'Movement': function () {},
        'Retreat': function () {},
        'Adjustment': judgePreAdjustment
    };

    // TODO(ccraciun): Move this to util.js?
    function getNext(arr, it) {
        var idx = arr.indexOf(it);
        if (idx === -1) {
            return undefined;
        }
        return arr[idx + 1];
    };

    function nextTurn(turn) {
        var newYear = turn.year,
            newSeason = turn.season,
            newPhase = turn.phase;

        newPhase = getNext(phases, newPhase);
        if (newPhase) {
            return {year: newYear, season: newSeason, phase: newPhase};
        };
        newPhase = phases[0];
        newSeason = getNext(seasons, newSeason);
        if (!newSeason) {
            newSeason = seasons[0];
            ++newYear;
        };
        if (_(adj_seasons).contains(newSeason)) {
            newPhase = 'Adjustment';
        }
        return {year: newYear, season: newSeason, phase: newPhase};
    };

    function judgeMovement(state, orders) {
        // Invalid orders.
        // Disrupted support.
        // Fail dislodged convoys.
        // Fail non-adjacent movements that are not convoyed.
        // Fail bounces.
        // Special cases.
        return undefined;
    };

    function judgePreAdjustment(stateIn) {
        for (power in state.forces) {
            for (type in state.forces[power]) {
                for (idx in state.forces[power][type]) {
                    loc = state.forces[power][type][idx];
                    loc = defs.canonical[loc] || loc;
                    if (loc in state.SC) {
                        state.SC[loc] = power;
                    };
                };
            };
        };
    };

    function judgeAdjustment(state, orders) {
        for (power in orders) {
            if (!_(defs.belligerents).contains(power)) {
                console.error(power + ' is not a belligerent but has orders.');
                return undefined;
            };
            if (!_(state.active).contains(power)) {
                console.error(power + ' is not active but has orders.');
                return undefined;
            };
        };
        _(state.active).each(function (power) {
            var adjustment = state.counts()[power].adjustment;
            // TODO(ccraciun): Consider reverse chronological order for orders 
            // since we might end up ignoring some.
            _(orders[power]).each(function (order) {
                if (adjustment > 0) {
                    if (order.act != 'build') {
                        order.result = 'fail';
                        return;
                    };
                    if (!_(defs.headquarters[power]).contains(order.org)) {
                        order.result = 'fail';
                        return;
                    };
                    if (state.forceAt(order.org) !== null){
                        order.result = 'fail';
                        return;
                    };
                    if (defs.adjacent[order.org][order.type].length == 0) {
                        order.result = 'fail';
                        return;
                    };
                    adjustment--;
                    order.success = true;
                } else if (adjustment < 0) {
                    if (order.act != 'disband') {
                        order.result = 'fail';
                        return;
                    };
                    if (state.forceAt(order.org) == null){
                        order.result = 'fail';
                        return;
                    };
                    if (state.forceAt(order.org).power !== order.pow) {
                        order.result = 'fail';
                        return;
                    };
                    adjustment++;
                    order.result = 'success';
                } else {
                    order.result = 'fail';
                };
            });
            if (adjustment < 0) {
                console.error(power + ' still needs to disband ' + (-adjustment) + ' forces but has not.');
                return undefined;
            };
        });
        return state;
    };

    function judgeRetreat(state, orders) {
        // Either annotate, or need access to movement orders/state to figure out
        // bad places to retreat.
        // Auto-disband if necessary.
        return undefined;
    };

    newState = new State(state);
    phaseJudge[state.date.phase](newState, orders);
    prePhaseJudge[newState.date.phase](newState);
};
