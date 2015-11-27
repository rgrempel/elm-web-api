var expect = require('chai').expect;
var count = require('count-substring');
var Q = require('q');

module.exports = function (browser) {
    var url;

    // Test for false, because null should default to true
    if (browser.desiredCapabilities.webStorageEnabled === false) {
        url = 'http://localhost:8080/elm-disable-storage.html';
    } else {
        url = 'http://localhost:8080/elm.html';
    }

    describe("The tests written in Elm", function () {
        var falsy = function () {
            return Q.when(false); 
        };

        it('should pass', function () {
            return browser
                .url(url)
                .waitUntil(function () {
                    return this.getText("#results").then(function (text) {
                        return text.indexOf("suites run") > 0;
                    }, falsy);
                }, 30000, 500)
                .getText("#results")
                .then(function (text) {
                    // Always log the test results
                    console.log(text);
                    
                    var failedCount = count(text, "FAILED");
                    expect(failedCount).to.equal(0);
                });
        });
    });
};

