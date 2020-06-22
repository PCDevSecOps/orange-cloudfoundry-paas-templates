#!/bin/bash

set -e
credhub curl -p api/info # to ensure credhub is available, as we ignore error on delete

set +e
echo "Credhub cleanup"
credhub d -n "/credhub_tls"
credhub d -n "/credhub_uaa_tls"