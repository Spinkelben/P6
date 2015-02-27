#!/bin/bash
SOURCE_DIR=$1
TARGET_DIR=$2

# move all apk files in the sourcedirs subdirs to targetdir.
echo Moving apks to target dir.
find $SOURCE_DIR -type f -name "*release*.apk" -exec mv -vn {} $TARGET_DIR \;

# remove all sourcedirs subdirectories.
echo Removing all subdirectories.
find $SOURCE_DIR -depth -type d -empty -exec rmdir -v {} \;

exit 0
