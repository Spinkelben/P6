#!/bin/bash
APK_FILE=$1

# Manual Entry
KEYSTORE_PATH=/srv/MainKeyStore.keystore
STORE_PASS=GirafMarius
KEY_ALIAS=googleplaykey
KEY_PASS=GirafMarius

KEY_VALIDITY_IN_DAYS=10000
#KEY_VALIDITY_IN_DAYS=1000000 # aprox: 2739726 years
RSA_KEYSIZE=2048
SIGNED_EXTENSION=release-signed.apk

echo Signing apk using default keystore.
# GENERATE KEYSTORE
# skip if using default keystore
#keytool -genkey -v -keystore $KEY_STORE_NAME -alias $KEY_ALIAS -keyalg RSA -keysize $RSA_KEYSIZE -validity $KEY_VALIDITY_IN_DAYS

# SIGN USING JARSIGNER
jarsigner -verbose -keystore $KEYSTORE_PATH -storepass $STORE_PASS -keypass $KEY_PASS $APK_FILE $KEY_ALIAS

# Extract app name from filename.
APP_NAME=$(echo $APK_FILE | cut -d "-" -f 1)
SIGNED_FILE_NAME="$APP_NAME-$SIGNED_EXTENSION"

# Rename apk file
echo Renaming apk file.
mv -f $APK_FILE $SIGNED_FILE_NAME

# VERIFY USING JARSIGNER
echo Verifying the signed apk.
jarsigner -verify $SIGNED_FILE_NAME
