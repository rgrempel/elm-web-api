var expect = require('chai').expect;
var Q = require('q');
var coverage = require('../coverage');

module.exports = function (browser) {
    var run;

    if (
        browser.desiredCapabilities.rafEnabled === false
    ) return;

    if (
        browser.desiredCapabilities.browserName == 'chrome' ||
        browser.desiredCapabilities.browserName == 'internet explorer' ||
        browser.desiredCapabilities.browserName == 'opera' ||
        browser.desiredCapabilities.browserName == 'iphone'
    ) {
        // Can't get the tab switching to work in these
        run = describe.skip;
    } else {
        run = describe;
    }

    // Test for false, because null should default to true
    if (browser.desiredCapabilities.webStorageEnabled === false) {
        // Skip if we've disabled web storage
        run = describe.skip;
    }

    var falsy = function () {
        return Q.when(false); 
    };

    run("The Storage example", function () {
        var url = 'http://localhost:8080/build/storage.html';
        
        before(function () {
            return browser
                .newWindow(url, "tab1")
                .waitForExist("#select-area", 6000)
                .selectByIndex("#select-area", 0)
                .selectByIndex("#select-operation", 5)
                .click("#perform-action")
                .newWindow(url, "tab2")
                .waitForExist("#select-area", 6000)
                .selectByIndex("#select-area", 0)
                .selectByIndex("#select-operation", 5)
                .click("#perform-action");
        });

        after(function () {
            return browser
                .switchTab("tab1")
                .then(function () {
                    return coverage.collect(browser);
                })
                .then(function () {
                    return browser
                        .close()
                        .switchTab("tab2")
                        .then(function () {
                            return coverage.collect(browser);
                        })
                        .then(function () {
                            return browser.close();
                        });
                });
        });

        it("first set should trigger add event", function () {
            // These expecteText checks are a little lazy, since the actual
            // order of the properties is not necessarily deterministic -- it
            // changed between Elm 0.15 and 0.16, for instance. But, at least
            // if it passes, I know it's good -- it's failure that might be
            // mistaken.
            var expectedText = "LogEvent { area = Local, url = \"" + url + "\", change = Add \"testKey\" \"testValue\" }";
            return browser
                .switchTab("tab1")
                .waitForExist("#select-area", 6000)
                .selectByIndex("#select-area", 0)
                .selectByIndex("#select-operation", 3)
                .waitForExist("#select-set-key", 6000)
                .setValue("#select-set-key", "testKey")
                .setValue("#select-set-value", "testValue")
                .click("#perform-action")
                .switchTab("tab2")
                .waitUntil(function () {
                    return this.getText("#log").then(function (text) {
                        return text.indexOf(expectedText) >= 0;
                    });
                }, 8000, 250);
        });
        
        it("second set should trigger modify event", function () {
            var expectedText = "LogEvent { area = Local, url = \"" + url + "\", change = Modify \"testKey\" \"testValue\" \"testValue2\" }";

            return browser
                .switchTab("tab1")
                .setValue("#select-set-key", "testKey")
                .setValue("#select-set-value", "testValue2")
                .click("#perform-action")
                .switchTab("tab2")
                .waitUntil(function () {
                    return this.getText("#log").then(function (text) {
                        return text.indexOf(expectedText) >= 0;
                    });
                }, 8000, 250);
        });
        
        it("remove should trigger remove event", function () {
            var expectedText = "LogEvent { area = Local, url = \"" + url + "\", change = Remove \"testKey\" \"testValue2\" }";

            return browser
                .switchTab("tab1")
                .selectByIndex("#select-operation", 4)
                .waitForExist("#select-remove-key", 6000)
                .setValue("#select-remove-key", "testKey")
                .click("#perform-action")
                .switchTab("tab2")
                .waitUntil(function () {
                    return this.getText("#log").then(function (text) {
                        return text.indexOf(expectedText) >= 0;
                    });
                }, 8000, 250);
        });
        
        it("clear should trigger clear event", function () {
            var expectedText = "LogEvent { area = Local, url = \"" + url + "\", change = Clear }";

            return browser
                .switchTab("tab1")
                .selectByIndex("#select-operation", 3)
                .waitForExist("#select-set-key", 6000)
                .setValue("#select-set-key", "testKey")
                .setValue("#select-set-value", "testValue")
                .click("#perform-action")
                .selectByIndex("#select-operation", 5)
                .click("#perform-action")
                .switchTab("tab2")
                .waitUntil(function () {
                    return browser.getHTML("#log").then(function (text) {
                        return text.indexOf(expectedText) >= 0;
                    }, falsy);
                }, 8000, 250);
        }); 
    });
};
