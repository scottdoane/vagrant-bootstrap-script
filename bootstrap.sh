#!/usr/bin/env bash
#
# Script to bootstrap the vagrant environment
# This development environment depends on external github resources
#
# Usage
#
# If the passwords or keys need to be updated
# Use the following:
# openssl smime -encrypt -aes256 -in $FILE -binary -outform DER -out $FILE.enc $PUBFILE

# Configure name of the pub/private key pair
# Directory is assumed to be relative to the bootstra.sh script
KEYFILE=''
PUBFILE=''

# Configure necessary bits for subversion access
SVN_USER=''
SVN_PASS=''
SVN_REPO=''

# Configure any github repos that need to be pulled in
# This is kind of a hacky "hash" for bash
# Enter in the repo, followed by the name of the target directory
#
# Example:
# GITHUB=( "scottdoane/puppet-privy:privy" )
# repo is scottdoane/puppet-privy
# exports to ./privy
GITHUB=( "" )

#
#   DO NOT EDIT BELOW THIS LINE
#
GIT=`which git`
SVN=`which svn`
VAGRANT=`which vagrant`

# Validate the public/private keypair to ensure successful decryption
# If we fail, stop. Since nothing else afterwards will work properly.

key_md5=`openssl rsa -noout -modulus -in $KEYFILE | openssl md5`
pub_md5=`openssl x509 -noout -modulus -in $PUBFILE | openssl md5`

if [[ "$key_md5" == "$pub_md5" ]] ; then
  echo "Valid public/private keypair detected."
else
  echo "Invalid public/private keypair. Decryption will fail."
  echo "Halting bootstrap."
  cat $KEYFILE
  exit 1
fi

# This may be bad logic, hopping out of a broken if statement above?

# Iterate over the GITHUB array and clone the require repos
for module in "${GITHUB[@]}" ; do
  KEY="${module%%:*}"
  VALUE="${module##*:}"
  $GIT clone https://github.com/$KEY.git puppet/$VALUE
done

# Do the same for the puppet ones, but since we have a static pattern here
# we don't need any special kinds of configuration
$SVN export --username $SVN_USER --password $SVN_PASS $SVN_REPO puppet

# Start the vagrant service
$VAGRANT up

exit 0
