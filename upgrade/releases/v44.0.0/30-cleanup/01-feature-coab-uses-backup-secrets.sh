#!/bin/bash

echo "Credhub cleanup"
credhub delete -n "/secrets/shield_s3_bucket_prefix"
credhub delete -n "/secrets/shield_s3_secret_access_key"
credhub delete -n "/secrets/shield_s3_access_key_id"
credhub delete -n "/secrets/shield_s3_host"
