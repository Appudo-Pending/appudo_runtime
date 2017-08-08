#!/bin/bash
###########################################################################################
#    compile.sh is part of Appudo
#
#    Copyright (C) 2015
#        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################
set -v # verbose
set -e
if [ "$1" -eq 0  ]
then
echo RELEASE
T="Release"
LINK_OPT='-O3'
SWIFT_OPT='-O -gnone'
else
echo DEBUG
T="Debug"
LINK_OPT='-O0'
SWIFT_OPT='-Onone -g'
fi

SRC=$(realpath src)
MACHINE=$(uname -m)
P=$T.$MACHINE

if [ -d "$P" ]; then
    exit 0
fi

mkdir -p $P
cd $P

mkdir -p Packages
mkdir -p Packages/page
mkdir -p Packages/websocket

echo "compile modules..."
export TMPDIR=libappudo/build
mkdir -p libappudo/build
files=$(find $SRC/libappudo -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libappudo -emit-module-path=Packages/libappudo.swiftmodule  $files  -I Packages -I $SRC/libbridge

export TMPDIR=libassert/build
mkdir -p libassert/build
files=$(find $SRC/libassert -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libappudo_assert -emit-module-path=Packages/libappudo_assert.swiftmodule  $files  -I Packages -I $SRC/libbridge

export TMPDIR=appudo_page/build
mkdir -p appudo_page/build
files=$(find $SRC/appudo_page -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libappudo_special -emit-module-path=Packages/libappudo_special.swiftmodule  $files  -I Packages -I $SRC/libbridge
mv Packages/libappudo_special.swiftmodule Packages/page/libappudo_special.swiftmodule
mv Packages/libappudo_special.swiftdoc Packages/page/libappudo_special.swiftdoc

export TMPDIR=appudo_websocket/build
mkdir -p appudo_websocket/build
files=$(find $SRC/appudo_websocket -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libappudo_special -emit-module-path=Packages/libappudo_special.swiftmodule  $files  -I Packages -I $SRC/libbridge
mv Packages/libappudo_special.swiftmodule Packages/websocket/libappudo_special.swiftmodule
mv Packages/libappudo_special.swiftdoc Packages/websocket/libappudo_special.swiftdoc

export TMPDIR=libintern/build
mkdir -p libintern/build
files=$(find $SRC/libintern -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libintern -emit-module-path=Packages/libintern.swiftmodule $files -I Packages -I $SRC/libbridge

export TMPDIR=libintern_page/build
mkdir -p libintern_page/build
files=$(find $SRC/libintern_page -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libintern_page -emit-module-path=Packages/libintern_page.swiftmodule $files -I Packages -I Packages/page -I $SRC/libbridge

export TMPDIR=libintern_websocket/build
mkdir -p libintern_websocket/build
files=$(find $SRC/libintern_websocket -name "*.swift" | xargs)
swiftc $SWIFT_OPT -parse-as-library -save-temps -emit-bc -module-name=libintern_websocket -emit-module-path=Packages/libintern_page.swiftmodule $files -I Packages -I Packages/websocket -I $SRC/libbridge

echo "link modules..."
files=$(find libappudo -name "*.bc" | xargs)
llvm-link $files -o libappudo.bc

files=$(find libassert -name "*.bc" | xargs)
llvm-link $files -o libappudo_assert.bc

files=$(find appudo_page -name "*.bc" | xargs)
llvm-link $files -o libappudo_page.bc
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_page.bc none -r_T017libappudo_special:_T014libappudo_page
#$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_page.bc none -r_T0Spy17libappudo_special:_T0Spy14libappudo_page

files=$(find appudo_websocket -name "*.bc" | xargs)
llvm-link $files -o libappudo_websocket.bc
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_websocket.bc none -r_T017libappudo_special:_T019libappudo_websocket
#$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_websocket.bc none -r_T0Spy17libappudo_special:_T0Spy19libappudo_websocket

files=$(find libintern -name "*.bc" | xargs)
llvm-link $files -o libintern.bc

files=$(find libintern_page -name "*.bc" | xargs)
llvm-link $files -o libintern_page.bc
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libintern_page.bc none -r_T017libappudo_special:_T014libappudo_page
#$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libintern_page.bc none -r_T0Spy17libappudo_special:_T0Spy14libappudo_page

files=$(find libintern_websocket -name "*.bc" | xargs)
llvm-link $files -o libintern_websocket.bc
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libintern_websocket.bc none -r_T017libappudo_special:_T019libappudo_websocket
#$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libintern_websocket.bc none -r_T0Spy17libappudo_special:_T0Spy19libappudo_websocket

llvm-link libappudo.bc libappudo_assert.bc libintern.bc libintern_page.bc libintern_websocket.bc libappudo_page.bc libappudo_websocket.bc -o libappudo_full.bc

echo "patch modules..."
sed -e '/#/d' ../symbols.txt > symbols.tmp
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_full.bc llvm.used -a 0
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_full.bc T9libappudo7RunDataC -s __RunData_size
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_full.bc T9libappudo13AsyncInternalV -s __Async_size
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_full.bc swift.refcounted -s __SwiftAsync_offset
$SRC/../../appudo_llvm/Release.$(uname -m)/appudo_llvm libappudo_full.bc none -l symbols.tmp
rm symbols.tmp

echo "compile modules..."
llc -relocation-model=pic $LINK_OPT -filetype=obj libappudo_full.bc -o libappudo.o
ar r libappudo.a libappudo.o

rm -rf $SRC/../../appudo_master/userData2/Packages/$MACHINE
mkdir -p $SRC/../../appudo_master/userData2/Packages/$MACHINE/intern &> /dev/null
cp -r Packages/libintern.swift* $SRC/../../appudo_master/userData2/Packages/$MACHINE/intern/
cp -r $SRC/libbridge $SRC/../../appudo_master/userData2/Packages/$MACHINE/
cp -r Packages/page $SRC/../../appudo_master/userData2/Packages/$MACHINE/
cp -r Packages/websocket $SRC/../../appudo_master/userData2/Packages/$MACHINE/
cp -r Packages/libappudo.swift* $SRC/../../appudo_master/userData2/Packages/$MACHINE/
cp -r Packages/libappudo_assert.swift* $SRC/../../appudo_master/userData2/Packages/$MACHINE/
