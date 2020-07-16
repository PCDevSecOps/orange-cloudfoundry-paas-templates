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


# Init and unseal vault
./safe target -k https://$1 safe
./safe init --json > safe_keys.json
if [ $? -ne 0 ]; then
    exit 1
fi

# Store root token in credhub
ROOT_TOKEN=$(jq .root_token < safe_keys.json)
echo "Storing newly created root token in credhub"
credhub set -n /bosh-ops/vault/root_token -t password -w $ROOT_TOKEN

# Store unseal keys in credhub
for key in $(seq 0 4)
do
  echo "Storing unseal key number $((${key} + 1)) in credhub"
  KEY=$(jq .seal_keys[$key] < safe_keys.json)
  credhub set -n /bosh-ops/vault/unseal_key_${key} -t password -w $KEY
done

rm safe_keys.json

echo "You can now deploy the service again. Broker will be updated with the newly created root token"
