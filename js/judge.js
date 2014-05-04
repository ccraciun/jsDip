// judge(state, orders) -> state.
function judge(state, orders, defs) {
    // Default seasons are:
    // Spring -> Autumn -> Winter (Adjustments)
    // Changeable by defs.
    // Phases are:
    // (Non-Adjustment Season) Movement -> Retreat/Disband
    // (Adjustment Season) Adjust SC -> Build/Disband
    var phases = ['Movement', 'Retreat'],
        seasons = defs.seasons,
        adj_seasons = defs.adjustment_seasons;

    function getNext(arr, it) {
        var idx = arr.indexOf(it);
        if (idx === -1) {
            return null;
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
        if (newSeason in adj_seasons) {
            newPhase = 'Adjustment';
        }
        return {year: newYear, season: newSeason, phase: newPhase};
    };

    function judgeMovement(state) {
        // Invalid orders.
        // Fail dislodged convoys.
        // Fail non-adjacent movements that are not convoyed.
        // Fail bounces.
    };

    function judgeBuild(state) {
    };

    function judgeRetreat(state) {
    };
}
