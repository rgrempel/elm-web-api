var expect = require('chai').expect;
var Q = require('q');

module.exports = function (browser) {
    // Test for false, because null should default to true
    if (browser.desiredCapabilities.webStorageEnabled === false) return;

    describe("The Location example", function () {
        beforeEach(function (done) {
            browser.url('http://localhost:8080/build/location.html', done);
        });

        var falsy = function () {
            return Q.when(false); 
        };

        it("should reload from server", function () {
            return browser
                .setValue("#input", "This goes away on reload")
                .click("#reload-force-button")

                // Wait for it not to have a value again
                .waitUntil(function () {
                    return this.getValue("#input").then(function (value) {
                        return value === "";
                    }, falsy);
                }, 6000, 250);
        });
        
        it("should reload from cache", function () {
            return browser
                .setValue("#input", "This goes away on reload")
                .click("#reload-cache-button")

                // Wait for it not to have a value again
                .waitUntil(function () {
                    return this.getValue("#input").then(function (value) {
                        return value === "";
                    }, falsy);
                }, 6000, 250);
        });

        /* jshint laxbreak: true */
        var runError =
            browser.desiredCapabilities.browserName == "firefox"
                ? it
                : it.skip;

        describe("assign", function () {
            it("should work with valid url", function () {
                return browser
                    .setValue("#input", "http://localhost:8080/window.html")
                    .click("#assign-button")
                    .waitUntil(function () {
                        return this.url().then(function (url) {
                            return url.value == "http://localhost:8080/window.html";
                        });
                    }, 6000, 250);
            });
            
            runError("should error with invalid url", function () {
                return browser
                    .setValue("#input", "http:// www.apple.com")
                    .click("#assign-button")
                    .waitUntil(function () {
                        return this.getText("#message").then(function (message) {
                            return message.indexOf("Got error:") >= 0;
                        });
                    }, 6000, 250);
            });
        });
        
        describe("replace", function () {
            it("should work with valid url", function () {
                return browser
                    .setValue("#input", "http://localhost:8080/window.html")
                    .click("#replace-button")
                    .waitUntil(function () {
                        return this.url().then(function (url) {
                            return url.value == "http://localhost:8080/window.html";
                        });
                    }, 6000, 250);
            });
            
            runError("should error with invalid url", function () {
                return browser
                    .setValue("#input", "http:// www.apple.com")
                    .click("#replace-button")
                    .waitUntil(function () {
                        return this.getText("#message").then(function (message) {
                            return message.indexOf("Got error:") >= 0;
                        });
                    }, 6000, 250);
            });
        });
    });
};
