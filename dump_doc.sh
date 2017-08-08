#!/bin/bash
lynx -dump $(find $1 -name "*.html" -print0 | xargs -0) > check.txt
