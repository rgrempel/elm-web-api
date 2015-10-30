var expect = require('chai').expect;
var count = require('count-substring');
var htmlToText = require('html-to-text');

module.exports = function (browser) {
    var title =
        browser.desiredCapabilities.browserName + "-" +
        browser.desiredCapabilities.version + "-" +
        browser.desiredCapabilities.platform + " "
        browser.desiredCapabilities.build;
    
    describe(title, function () {
        this.timeout(300000);

        // We want to mark tht IE9 fails, but not fail the whole build for that reason
        var wasIE9 =
            browser.desiredCapabilities.browserName == "internet explorer" &&
            browser.desiredCapabilities.version == "9.0";

        var ie9passed = false;

        // Before any tests run, initialize the browser and load the test page.
        // Then call `done()` when finished.
        before(function (done) {
            browser.init(function (err) {
                if (err) throw err;
                browser.url('http://localhost:8080/elm.html', done);
            });
        });

        it('The tests written in Elm should pass', function (done) {
            setTimeout(function () {
                browser.getHTML("body", function (err, html) {
                    if (err) throw err;
                    
                    var passedCount = count(html, "All tests passed");
                    var failedCount = count(html, "FAILED");

                    if (passedCount != 1 || failedCount != 0) {
                        console.log("Failed!\n");
                        console.log(htmlToText.fromString(html));
                    }

                    if (wasIE9) {
                        // Keep track of whether ie9 passed, but don't fail the
                        // whole build.
                        ie9passed =
                            passedCount == 1 &&
                            failedCount == 0;
                    } else {
                        // Actually fail the build if we failed.
                        expect(passedCount).to.equal(1);
                        expect(failedCount).to.equal(0);
                    }

                    done();
                });
            }, 4000);
        });

        after(function (done) {
            if (wasIE9) {
                browser.passed(ie9passed, done);
            } else {
                browser.passed(this.currentTest.state === 'passed', done);
            }
        });
    });
};
