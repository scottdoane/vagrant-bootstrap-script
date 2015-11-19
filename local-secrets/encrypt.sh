#!/usr/bin/env bash
#
# Script to encrypt contents of ./data and drop it into
# the local-encrypted folder
#

# Set path to local public key
PUBKEY=''

# Read all the files under ./data and encrypt them
for path in data/*; do

# Strip the directory data out of the pathname
# If we don't, they try to land in local-encrypted/data
file="${path##*/}"

# Feedback is always nice...
echo "Encrypting $path into ../local-encrypted/$file.enc"

# Encrypt the files
openssl smime \
  -encrypt \
  -aes256 \
  -in data/$file \
  -binary \
  -outform DER \
  -out ../local-encrypted/$file.enc \
  $PUBKEY
done;

exit 0
