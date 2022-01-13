#!/bin/bash
echo "this script must be executed on feature-coabdepls-<service>-serviceinstances branch"
echo "this script generates a file containing coab deployments (backing) service instance guid without x-osb-cmdb: property in their coab-vars.yml"
rm coab.lst
for file in $(find . -name coab-vars.yml);do
  grep -v "x-osb-cmdb: " ${file} | grep deployment_name | cut -d: -f2 >> coab.lst
done
cat coab.lst | sort | cut -d'"' -f2 | grep "_" | cut -d_ -f2 > missingx_osb_cmdb.lst
