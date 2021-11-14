#!/usr/bin/bash
set -e

sed -n '/START_KEYS/,/END_KEYS/p' ~/.xmonad/xmonad.hs | \
    grep -e ', ("' \
    -e '\[ (' \
    -e 'KB_GROUP' | \
    grep -Ev '\-\-\s+, \("' | \
    sed -e 's/^[ \t]*//' \
    -e 's/, (/(/' \
    -e 's/\[ (/(/' \
    -e 's/-- KB_GROUP /\n/' \
    -e 's/", /"\t/' | \
    awk -F '\t' ' { print sprintf("%-30s %s ", $1, $2) } '
