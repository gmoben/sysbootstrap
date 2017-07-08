#!/bin/bash

pushd $HOME/.ssh

echo "Start Export Process"

echo "Log into Keybase..."
keybase login

echo "Exporting your PGP keys..."
# Exporting your Keybase public key to keybase.public.key
keybase pgp export -o keybase.public.key
# Exporting your Keybase private key to keybase.private.key
keybase pgp export -s -o keybase.private.key

echo "Importing your Keybase keys..."
# Import your Keybase public key
gpg -q --import keybase.public.key
# Import your Keybase private key
gpg -q --allow-secret-key-import --import keybase.private.key
# The key import process produces a short hexadecimal hash
# We need to extract this hash and use it to generate the RSA key
# The hash is temporarily saved into hash.key
sudo gpg --list-keys | grep '^pub\s*.*\/*.\s.*' | grep -oEi '\/(.*)\s' | cut -c 2- | awk '{$1=$1};1' > hash.key

echo "Generating RSA keys..."
# Generate the RSA private key using the hexadecimal hash
# The private key will be saved in the id_rsa file
sudo gpg --export-options export-reset-subkey-passwd,export-minimal,no-export-attributes --export-secret-keys --no-armor `cat hash.key` | sudo openpgp2ssh `cat hash.key` > id_rsa
# Secure the private RSA key file
sudo chmod 400 id_rsa
# Generate the public RSA key file
sudo ssh-keygen -y -f id_rsa > id_rsa.pub

echo "Cleaning up..."
# Remove all the temporary files
rm *.key

echo "Success"

popd
