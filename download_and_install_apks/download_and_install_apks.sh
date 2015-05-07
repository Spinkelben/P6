#!/bin/bash
ftp -i ftp://ftpuser:9scWKbP@cs-cust06-int.cs.aau.dk/newest_releases/ << SCRIPTEND
binary
mget *
SCRIPTEND

for f in *.apk ; do
    adb install -r "$f" ;
done
