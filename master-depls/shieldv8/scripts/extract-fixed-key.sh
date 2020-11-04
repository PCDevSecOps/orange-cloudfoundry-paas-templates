#!/bin/bash

#This script extract vault fixed key on shield VM

#Get root token
/var/vcap/packages/shield/bin/shield op pry /var/vcap/store/shield/vault.crypt
export VAULT_CLIENT_CERT=/var/vcap/jobs/core/config/tls/vault.pub
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CLIENT_KEY=/var/vcap/jobs/core/config/tls/vault.key
export VAULT_SKIP_VERIFY=true

#Connect to vault and collect encryption information
echo "connect to vault and extract encryption information..."
/var/vcap/packages/vault/bin/vault auth
/var/vcap/packages/vault/bin/vault read secret/secret/archives/fixed_key