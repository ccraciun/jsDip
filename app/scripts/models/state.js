function window.State(info) {
    var self = this,
        _counts = null;

    this.counts = function () {
        if (!_counts) {
            _counts = {};

            for (power in self.SCs) {
                _counts[power] = _counts[power] || {};
                _counts[power].SCs = self.SCs[power].length;
            }

            for (power in self.forces) {
                _counts[power] = _counts[power] || {};
                _counts[power].armies = self.forces[power].armies.length;
                _counts[power].fleets = self.forces[power].fleets.length;
                _counts[power].forces = _counts[power].armies +
                                        _counts[power].fleets;
                _counts[power].adjustment = _counts[power].SCs -
                                            _counts[power].forces;
            }
        }
        return _counts;
    };

    this.forceAt = function (loc) {
        for (power in self.forces) {
            for (type in self.forces[power]) {
                if (loc in self.forces[power][type]) {
                    return {power: power, type: type};
                }
            }
        }
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
            }
            self.SC[loc] = power;
        });
    });
}
