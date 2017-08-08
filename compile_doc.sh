#!/bin/bash
###########################################################################################
#    compile_doc.sh is part of Appudo
#
#    Copyright (C) 2015
#        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

FILES=$(find $1 -name "*.swift" | xargs)
mkdir ./build
while true; do
	rm -rf ./build/*
	TMPDIR=./build  swiftc $FILES -fixit-code -save-temps -emit-module -module-name doc -I $1/libbridge -o out -v
	ERROR=$?

	if [ $ERROR -eq 0 ]; then
		break
	fi
	python ./apply-fixit-edits.py ./build/
done
