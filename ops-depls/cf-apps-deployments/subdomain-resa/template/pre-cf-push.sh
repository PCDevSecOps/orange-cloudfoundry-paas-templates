#!/bin/sh -e
echo "creating subdomain-resa application"

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf target -s $CF_SPACE -o $CF_ORG

