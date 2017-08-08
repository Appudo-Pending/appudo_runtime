#!/bin/bash
find "$1" -name "*.html" -exec sed -i "s/Appudo Docs/Appudo$2 Docs/g" {} \;
find "$1" -name "*.html" -exec sed -i "s/Appudo  Reference/Appudo$2  Reference/g" {} \;
find "$1" -name "*.html" -exec sed -i "s/Appudo Reference/Appudo$2 Reference/g" {} \;
