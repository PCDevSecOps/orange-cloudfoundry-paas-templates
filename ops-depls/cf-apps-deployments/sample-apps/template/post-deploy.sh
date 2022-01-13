#!/bin/bash

API_OPTIONS="--skip-ssl-validation"

cf api "$CF_API_URL" $API_OPTIONS
cf auth "$CF_USERNAME" "$CF_PASSWORD"

cf target -o "$CF_ORG" -s "$CF_SPACE"

echo "Getting deployed apps"
deployed_apps=$(cf apps|grep "cf-"|cut -d' ' -f1)

for app in ${deployed_apps};do
  echo "Extracting info from $app"
  cf app $app > /tmp/app-info.txt
  app_buildpacks=$(cat /tmp/app-info.txt|grep -E "^buildpacks:"|sed -e "s/buildpacks:[[:space:]]*//")
  app_stack=$(cat /tmp/app-info.txt|grep -E "^stack:"|sed -e "s/stack:[[:space:]]*//")
  cf set-label app $app app-buildpacks="${app_buildpacks}" app-stack="${app_stack}"
done

echo "Selecting cflinuxfs3 app"
cf apps --labels 'app-stack=cflinuxfs3'