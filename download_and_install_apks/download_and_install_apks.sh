#!/bin/bash
noglob ftp -i ftp://ftpuser:9scWKbP@cs-cust06-int.cs.aau.dk/newest_releases/ << SCRIPTEND
binary
mget *
SCRIPTEND

for f in *.apk ; do
    adb uninstall ${f%'.apk'};
    adb install -r "$f" ;
done
