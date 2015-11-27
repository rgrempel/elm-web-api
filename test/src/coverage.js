var istanbul = require('istanbul');
var collector = new istanbul.Collector();
var reporter = new istanbul.Reporter(null, "build/coverage");

module.exports = {
    collect : function (browser) {
        return browser.execute("return window.__coverage__;").then(function (obj) {
            collector.add(obj.value);
        });
    },

    report : function (done) {
        reporter.add('text');
        reporter.addAll([ 'lcov', 'clover' ]);
        reporter.write(collector, false, function () {
            done();
        });
    }
};
