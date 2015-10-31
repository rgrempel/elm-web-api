#!/bin/sh

# Abort on error ...
set -e

elm-make ../src/CI.elm --output elm.html
elm-make ../../examples/src/WindowExample.elm --output window.html
elm-make ../../examples/src/LocationExample.elm --output location.html

mocha --delay run.js
