#!/bin/sh

echo "Params: $*"
CONFIG_DIR="$1"

cf purge-service-offering o-internet-access -f
cf purge-service-offering p-rabbitmq -b p-rabbitmq -f


