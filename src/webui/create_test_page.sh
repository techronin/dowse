#!/bin/bash

FILE=src/*.c
cproto ${FILE} -I../libparse-datetime -I/usr/include/mysql -I../kore/includes -Isrc/|sed "s/([^;]*;//"|awk '/___webui___test_unit/ {i++; print "static /"i" "$2" "}'| while read f; do
	echo $f
done