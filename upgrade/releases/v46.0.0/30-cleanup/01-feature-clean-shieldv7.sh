#!/bin/bash

echo "Credhub cleanup"
credhub delete -n "/secrets/shield_obos_bucket_prefix"
credhub delete -n "/secrets/shield_obos_secret_access_key"
credhub delete -n "/secrets/shield_obos_access_key_id"
credhub delete -n "/secrets/shield_basic_password"
credhub delete -n "/secrets/shield_autoprovision_key"
credhub delete -n "/secrets/backup_local_s3_secret_access_key"
credhub delete -n "/secrets/backup_local_s3_access_key_id"
credhub delete -n "/secrets/backup_local_s3_host"