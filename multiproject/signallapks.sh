#!/bin/bash
################################
# Sign all apks                #
################################
SOURCE_DIR=$1
SCRIPT_DIR=/srv/scripts
TARGET_DIR="$SOURCE_DIR/signed"
KEYSTORE_PATH=/srv/MainKeyStore.keystore
STORE_PASS=GirafMarius
KEY_ALIAS=googleplaykey
KEY_PASS=GirafMarius

# remove target directory if it exists.
#rm -rf $TARGET_DIR

# make target directory
mkdir -p $TARGET_DIR

# move all apks to target dir.
$SCRIPT_DIR/moveAPKsToDir.sh "$SOURCE_DIR" "$TARGET_DIR"

# Sign all apks using keystore.
FILES="$TARGET_DIR/*.apk"
for f in $FILES
do
  echo "Processesing file: $f..."
  $SCRIPT_DIR/signAPK.sh "$f" "$KEYSTORE_PATH" "$STORE_PASS" "$KEY_ALIAS" "$KEY_PASS"
done

echo ### DONE ! ###

exit 0
