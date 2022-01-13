#!/bin/sh


for app in cf-sample-app-python cf-default-app-ruby cf-sample-app-nodejs cf-sample-app-go
do
    echo "Cloning ${app}"
    git clone --depth 1 https://github.com/swisscom/${app} ${GENERATE_DIR}/${app}
done

for app in cf-sample-app-php
do
    echo "Cloning ${app}"
    git clone --depth 1 https://github.com/orange-cloudfoundry/${app} ${GENERATE_DIR}/${app}
done

cf create-org "$CF_ORG"
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"
