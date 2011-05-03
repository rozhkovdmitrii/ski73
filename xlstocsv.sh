#!/bin/bash
xls2csv -b"__newsheet" $1 2>/dev/null | grep -vE "^(\"[0-9]+\")?,+$" > $2
#(\"\\d\+\")\?
