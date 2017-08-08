#!/bin/bash
###########################################################################################
#    clean.sh is part of Appudo
#
#    Copyright (C) 2015
#        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

echo "clean appudo_runtime..."

MACHINE=$(uname -m)
P="*.$MACHINE"
rm -rf $P &> /dev/null
