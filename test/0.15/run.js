var SeSauce = require('selenium-sauce');
var expect = require('chai').expect;
var git = require('git-rev');
var count = require('count-substring');
var htmlToText = require('html-to-text');

var remote = require('./remote');
var config = require('./config');

git.short(function (rev) {
    // If SauceLabs environment variables are present, set up SauceLabs browsers
    if (config.webdriver.user) {
        config.webdriver.desiredCapabilities = remote(rev);
    } else {
        config.webdriver.desiredCapabilities = [{
            browserName: 'chrome'
        }];
    };

    // Loads the config file and invokes the callback once for each browser 
    new SeSauce(config, function (browser) {
        var title =
            browser.desiredCapabilities.browserName + "-" +
            browser.desiredCapabilities.version + "-" +
            browser.desiredCapabilities.platform + " "
            browser.desiredCapabilities.build;
        
        describe(title, function () {
            this.timeout(120000);

            // Before any tests run, initialize the browser and load the test page.
            // Then call `done()` when finished.
            before(function (done) {
                browser.init(function (err) {
                    if (err) throw err;
                    browser.url('http://localhost:8080/elm.html', done);
                });
            });

            it('should succeed twice', function (done) {
                setTimeout(function () {
                    browser.getHTML("body", function (err, html) {
                        if (err) throw err;
                        
                        var passedCount = count(html, "All tests passed");
                        var failedCount = count(html, "FAILED");

                        if (passedCount != 2 || failedCount != 0) {
                            console.log("Failed!\n");
                            console.log(htmlToText.fromString(html));
                        }

                        expect(passedCount).to.equal(2);
                        expect(failedCount).to.equal(0);
    
                        done();
                    });
                }, 4000);
            });

            after(function (done) {
                browser.passed(this.currentTest.state === 'passed', done);
            });
        });
    });

    run();
});

