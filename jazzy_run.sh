#!/bin/bash
DOC=$1
VER=0.1.30
VPREFIX=SNAPSHOT
shift 

EX=''
for ITEM in "$@"
do
    EX+='-o -path "*'
    EX+="$ITEM"
    EX+='*" '
done

EXEC='find . -name "*_Private.swift" '$EX
echo $EXEC
FILES=$(eval $EXEC | xargs)
EX=''

for FILE in $FILES
do
    EX+="$FILE,"
done

if [ "$DOC" == " " ]; then
	DOC=""
fi

TARGET=docs"$DOC"_$VER
rm -rf $TARGET
rm -rf docs/*
jazzy -m Appudo --skip-undocumented --hide-documentation-coverage -a source@appudo.com -g https://www.github.com/Appudo --module-version "$VPREFIX-$VER" -e$EX
mv docs $TARGET
