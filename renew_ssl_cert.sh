#!/bin/bash

set -e

TARGET_CRT_FILE='/etc/ssl/certs/opensnp.org.crt'
DEHYDRATED_DIR='/tmp/dehydrated'
WELLKNOWN_DIR='/home/app/snpr/public/.well-known/acme-challenge'

if [ ! -f $TARGET_CRT_FILE ]; then
  echo "No certificate found to renew."
  exit 0
fi

expiration_date=$(openssl x509 -enddate -noout -in $TARGET_CRT_FILE | cut -d = -f 2)
days_until_expiration=$(( ($(date -d "$expiration_date" +%s) - $(date +%s)) / (60*60*24) ))

if [ $days_until_expiration -gt 10 ]; then
  echo 'Plenty of time to renew, exiting.'
  exit 0
fi

echo 'Cloning dehydrated...'
git clone https://github.com/lukas2511/dehydrated.git $DEHYDRATED_DIR
cd $DEHYDRATED_DIR
git checkout tags/v0.4.0

cp docs/examples/config config
mkdir -p $WELLKNOWN_DIR

# by default, WELLKNOWN is commented out, so just set the variable
echo "WELLKNOWN=$WELLKNOWN_DIR" >> config

echo 'opensnp.org www.opensnp.org' > domains.txt

echo 'Starting dehydrated...'

./dehydrated --cron --accept-terms


echo 'Done, now copying keys'
cp /etc/ssl/private/opensnp.org.key /etc/ssl/private/opensnp.org.key.old
cp $DEHYDRATED_DIR/certs/opensnp.org/privkey.pem /etc/ssl/private/opensnp.org.key
cp $TARGET_CRT_FILE $TARGET_CRT_FILE.old
cp $DEHYDRATED_DIR/certs/opensnp.org/fullchain.pem $TARGET_CRT_FILE

service nginx restart

echo 'Cleaning up...'
rm -rf $DEHYDRATED_DIR
echo 'Bye!'
