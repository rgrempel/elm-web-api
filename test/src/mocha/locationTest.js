var expect = require('chai').expect;
var Q = require('q');

module.exports = function (browser) {
    describe("The Location example", function () {
        beforeEach(function (done) {
            browser.url('http://localhost:8080/location.html', done);
        });

        it("should reload from server", function () {
            return browser
                .setValue("#input", "This goes away on reload")
                .click("#reload-force-button")

                // Wait for it not to have a value again
                .waitForValue("#input", 12000, true);
        });
        
        it("should reload from cache", function () {
            return browser
                .setValue("#input", "This goes away on reload")
                .click("#reload-cache-button")

                // Wait for it not to have a value again
                .waitForValue("#input", 12000, true);
        });
    });
};
