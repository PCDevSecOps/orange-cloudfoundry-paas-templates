#!/bin/bash
cf t -o system_domain
echo "Listing existing spaces in 'system_domain' org"
spaces=$(cf spaces)
echo "Removing useless spaces"
cf_version=$(cf --version)

space_name="stratos-ui-v2"
if [[ "$cf_version" =~ ^(cf version 6\.).* ]]; then
  echo "cf cli 6 detected - Using legacy mode"
  existing_space=$(cf spaces|grep -e "^$space_name$")
  if [ "$existing_space" = "$space_name" ]; then
    cf delete-space $space_name -o system_domain -f
  else
    echo "$space_name already deleted"
  fi
else
  echo "cf cli 7 detected"
  cf delete-space $space_name -o system_domain -f
fi
