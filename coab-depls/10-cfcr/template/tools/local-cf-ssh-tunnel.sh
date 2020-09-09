#!/bin/sh
cf target -s kubedashboard-proxy #must be space developer on this space
cf ssh -L 8443:cfcr-api.internal.paas:443 kubedashboard-proxy
