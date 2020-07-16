#!/bin/sh


for app in cf-sample-app-python cf-default-app-ruby cf-sample-app-nodejs cf-sample-app-php cf-sample-app-go
do
    git clone --depth 1 https://github.com/swisscom/${app} ${GENERATE_DIR}/${app}
done

cf create-org "$CF_ORG"
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"
