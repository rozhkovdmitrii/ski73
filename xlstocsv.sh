#!/bin/bash
xls2csv -b"__newsheet" $1 2>/dev/null | grep -v "^,\+$" > $2
#(\"\\d\+\")\?
