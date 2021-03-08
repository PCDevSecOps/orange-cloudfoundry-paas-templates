#!/bin/bash



# please log onto credhub before using the script
# get variables from credhub

cloudfoundry_system_domain="$(credhub get --name /secrets/cloudfoundry_system_domain | grep "value:" | cut -d " " -f 2)"
cf_blobstore_s3_accesskey="$(credhub get --name /bosh-master/cloudfoundry-datastores/cf_blobstore_s3_accesskey | grep "value:" | cut -d " " -f 2)"
cf_blobstore_s3_secretkey="$(credhub get --name /bosh-master/cloudfoundry-datastores/cf_blobstore_s3_secretkey | grep "value:" | cut -d " " -f 2)"

obos_s3_accesskey="$(credhub get --name /secrets/shield_obos_access_key_id | grep "value:" | cut -d " " -f 2)"
obos_s3_secretkey="$(credhub get --name /secrets/shield_obos_secret_access_key | grep "value:" | cut -d " " -f 2)"





echo -e "\033[33;32m Starting transfering blobstore from minio s3 to obos \033[0m"

wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O mc
chmod +x mc

cat >~/.mc/config.json <<EOL
{
"version": "8",
"hosts": {
"obos": {
"url": "https://storage.orange.com:443",
"accessKey": "${obos_s3_accesskey}",
"secretKey": "${obos_s3_secretkey}",
"api": "S3v2"
 },
"minio": {
"url": "http://cf-datastores.internal.paas:9000",
"accessKey": "${cf_blobstore_s3_accesskey}",
"secretKey": "${cf_blobstore_s3_secretkey}",
"api": "S3v2"
}
}
}
EOL

# create missing buckets if not exist
# the script will show an error if bcukets is already exist , please ignor it

./mc mb "obos/${cloudfoundry_system_domain}-cc-buildpacks"
./mc mb "obos/${cloudfoundry_system_domain}-cc-droplets"
./mc mb "obos/${cloudfoundry_system_domain}-cc-packages"
./mc mb "obos/${cloudfoundry_system_domain}-cc-resources"





echo "Begin Transfering files from minio to OBOS"

 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-buildpacks" "obos/${cloudfoundry_system_domain}-cc-buildpacks"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-droplets" "obos/${cloudfoundry_system_domain}-cc-droplets"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-packages" "obos/${cloudfoundry_system_domain}-cc-packages"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-resources" "obos/${cloudfoundry_system_domain}-cc-resources"
echo "End of transfert"



