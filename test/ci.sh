#!/bin/sh

# Abort on error ...
set -e

elm-make ../src/elm/CI.elm --output elm.html
elm-make ../../examples/src/WindowExample.elm --output window.html
elm-make ../../examples/src/LocationExample.elm --output location.html

mocha --delay ../src/run.js
