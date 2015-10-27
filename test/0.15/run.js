var SeSauce = require('selenium-sauce');
var expect = require('chai').expect;
var git = require('git-rev');
var count = require('count-substring');
var htmlToText = require('html-to-text');

var sauceUserName = process.env.GEB_SAUCE_LABS_USER;
var sauceAccessKey = process.env.GEB_SAUCE_LABS_ACCESS_PASSWORD;

var config = {
    // Configuration options    
    quiet: false,           // Silences the console output 

    webdriver: {            // Options for Selenium WebDriver (WebdriverIO) 
        user: sauceUserName,
        key: sauceAccessKey
    },

    httpServer: {           // Options for local http server (npmjs.org/package/http-server) 
        disable: false,
        port: 8080              // Non-standard option; it is passed into the httpServer.listen() method 
    },

    sauceLabs: {            // Options for SauceLabs API wrapper (npmjs.org/package/saucelabs)
        username: sauceUserName,
        password: sauceAccessKey
    },

    sauceConnect: {         // Options for SauceLabs Connect (npmjs.org/package/sauce-connect-launcher)
        disable: false,
        username: sauceUserName,
        accessKey: sauceAccessKey
    },
    
    selenium: {             // Options for Selenium Server (npmjs.org/package/selenium-standalone). Only used if you need Selenium running locally.
        args: []                // options to pass to `java -jar selenium-server-standalone-X.XX.X.jar`
    }
};

git.short(function (rev) {
    // If SauceLabs environment variables are present, set up SauceLabs browsers
    if (sauceUserName && sauceAccessKey) {
        config.webdriver.desiredCapabilities = [/*{
            browserName: 'chrome',
            version: '27',
            platform: 'XP',
            public: 'public',
            build: rev,
            name: rev
        },{
            browserName: 'firefox',
            version: '41',
            platform: 'Linux',
            public: 'public',
            build: rev,
            name: rev
        },*/{
            browserName: 'safari',
            version: '9.0',
            platform: 'OS X 10.11'
        }];
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

