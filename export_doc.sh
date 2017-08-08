#!/bin/bash
###########################################################################################
#    export_doc.sh is part of Appudo
#
#    Copyright (C) 2015
#        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

rm -r doc/*
cp -r src/libbridge doc/
cp -r src/appudo_page doc/
cp -r src/appudo_websocket doc/
rm doc/appudo_websocket/appudo/User.swift
cp -r src/libappudo doc/
cp -r src/libassert doc/
cp -r src/libenv doc/

FILES=$(find doc/* -name "*.swift" | xargs)
echo $files
COUNT=0
for FILE in $FILES
do
        BASE=$(basename "$FILE")
        DIR=$(dirname "$FILE")
        NAME="${BASE%.[^.]*}"
        FROM="$DIR/$NAME.swift"
        TO="$DIR/$NAME$COUNT.swift"
        grep -Evw "import libappudo" $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/\([:|>|=]\s*\(inout\)*\s*\)AsyncStruct<\([^>]*\(<[^>]*>\)*\)>/\1AsyncValue<\3?>/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/\([:|>|=]\s*\(inout\)*\s*\)AsyncClass<\([^>]*\(<[^>]*>\)*\)>/\1AsyncValue<\3?>/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/\([:|>|=]\s*\(inout\)*\s*\)AsyncStruct(/\1AsyncValue(/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/\([:|>|=]\s*\(inout\)*\s*\)AsyncClass(/\1AsyncValue(/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/(OpaquePointer(bitPattern:\([^)]*\)))/(\1).toOpaque()/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/fromOpaque(OpaquePointer/fromOpaque(UnsafePointer<Void>/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/initialize(with:/initialize(to:/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/UInt = NSUTF8StringEncoding/String.Encoding = NSUTF8StringEncoding/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/NSTimeZone/TimeZone/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        sed -e 's/JSON: Swift.BooleanType/JSON/g' $FROM > $DIR/temp && mv $DIR/temp $FROM
        mv $FROM $TO
        ((COUNT+=1))
done
