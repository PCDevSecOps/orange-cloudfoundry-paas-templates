#!/bin/bash
set +e
CONFIG_REPO=$1

echo "ops-routing secrets cleanup..."

credhub delete -n /bosh-master/ops-routing/uaa_ca

set -e