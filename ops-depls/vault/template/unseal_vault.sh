#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "You must provide one of the vault instance address ip as parameter"
    exit 1
fi

# Are you authenticated to credhub?
credhub find >> /dev/null
if [ $? -ne 0 ]; then
    echo "Please first authenticate to credhub"
    exit 1
fi

# Download safe client
echo "Downloading safe client"
wget -q https://github.com/starkandwayne/safe/releases/download/v1.0.0/safe-linux-amd64 -O safe
chmod +x safe

./safe target -k https://$1 safe

# Retrieve unseal keys from credhub
for key in $(seq 0 4)
do
  echo "Key $((${key} + 1)):"
  credhub get -n /bosh-ops/vault/unseal_key_${key}  -j | jq .value | sed 's/"//g'
done

# Unseal the vault (manual action required)
./safe unseal
