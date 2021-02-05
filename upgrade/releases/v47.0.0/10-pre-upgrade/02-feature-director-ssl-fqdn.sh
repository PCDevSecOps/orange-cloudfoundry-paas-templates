#!/bin/bash

set -e
credhub curl -p api/info # to ensure credhub is available, as we ignore error on delete

set +e
echo "Credhub cleanup for director SSL FQDN"
CREDHUB_REFS=$(credhub f -j|jq '.[]|.[]|.name|select(endswith("/director_ssl") == true)')
for ref in ${CREDHUB_REFS}; do
    echo "Removing $ref"
    credhub d -n ${ref}
done
