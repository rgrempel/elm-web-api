var windowTest = require('./windowTest');
var elmTest = require('./elmTest');

module.exports = function (browser) {
    var title =
        browser.desiredCapabilities.browserName + "-" +
        browser.desiredCapabilities.version + "-" +
        browser.desiredCapabilities.platform + " "
        browser.desiredCapabilities.build;
    
    describe(title, function () {
        this.timeout(600000);
        this.slow(4000);

        // Before any tests run, initialize the browser.
        before(function (done) {
            browser.init(function (err) {
                if (err) throw err;
                done();
            });
        });

        elmTest(browser);
        windowTest(browser);

        after(function (done) {
            var passed = this.currentTest.state === 'passed';
            browser.passed(passed, done);
        });
    });
};
