#!/bin/bash
###########################################################################################
#    setup_swift.sh is part of Appudo
#
#    Copyright (C) 2015-2016
#        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

if [ $1 -eq 0 ]; then
	sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
else
	sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
fi
