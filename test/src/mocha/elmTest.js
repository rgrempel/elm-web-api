var expect = require('chai').expect;
var count = require('count-substring');
var htmlToText = require('html-to-text');

module.exports = function (browser) {
    describe("The tests written in Elm", function () {
        it('should pass', function () {
            return browser
                .url('http://localhost:8080/elm.html')
                .waitUntil(function () {
                    return this.getHTML("body").then(function (html) {
                        var passedCount = count(html, "All tests passed");
                        var failedCount = count(html, "FAILED");

                        if (passedCount > 0) {
                            return true;
                        }

                        if (failedCount > 0) {
                            console.log("Failed!\n");
                            console.log(htmlToText.fromString(html));

                            throw "Failed tests written in Elm";
                        }

                        return false;
                    });
                }, 3000, 250);
        });
    });
};

