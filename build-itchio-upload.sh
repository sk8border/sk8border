#!/usr/bin/env bash
if [ ! -e ./index.html ] || [ ! -e ./index.js ]
then
    echo "Couldn't find index.html and/or index.js. Make sure to run this in the root of the repository."
    exit 1
fi

zip sk8border.zip ./index.html ./index.js './PICO-8 wide.ttf' 'ChevyRay - Softsquare FR.ttf'
