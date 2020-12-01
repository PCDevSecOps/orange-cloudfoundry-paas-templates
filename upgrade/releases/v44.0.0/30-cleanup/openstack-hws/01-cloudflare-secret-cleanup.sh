#!/bin/bash
CONFIG_REPO=$1
echo "Cloudflare secrets cleanup..."
rm -fv ${CONFIG_REPO}/cloudflare-depls/terraform-config/spec/cloudflare-org-space-id-lookup.tf
echo "Cloudflare secrets cleanup...OK"
