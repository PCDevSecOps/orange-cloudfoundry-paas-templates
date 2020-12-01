#!/bin/bash



# please log onto credhub before using the script
# get variables from credhub

cloudfoundry_system_domain="$(credhub get --name /secrets/cloudfoundry_system_domain | grep "value:" | cut -d " " -f 2)"
cf_blobstore_s3_accesskey="$(credhub get --name /bosh-master/cloudfoundry-datastores/cf_blobstore_s3_accesskey | grep "value:" | cut -d " " -f 2)"
cf_blobstore_s3_secretkey="$(credhub get --name /bosh-master/cloudfoundry-datastores/cf_blobstore_s3_secretkey | grep "value:" | cut -d " " -f 2)"




echo -e "\033[33;32m Starting transfering blobstore from current minio to minio cluster \033[0m"

wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O mc
chmod +x mc

cat >~/.mc/config.json <<EOL
{
"version": "8",
"hosts": {
"minio": {
"url": "http://192.168.99.217:9000",
"accessKey": "${cf_blobstore_s3_accesskey}",
"secretKey": "${cf_blobstore_s3_secretkey}",
"api": "S3v2"
 },
"newminio": {
"url": "http://192.168.99.125:9000",
"accessKey": "${cf_blobstore_s3_accesskey}",
"secretKey": "${cf_blobstore_s3_secretkey}",
"api": "S3v2"
}
}
}
EOL

# create missing buckets if not exist
# the script will show an error if bcukets is already exist , please ignor it

./mc mb "newminio/${cloudfoundry_system_domain}-cc-buildpacks"
./mc mb "newminio/${cloudfoundry_system_domain}-cc-droplets"
./mc mb "newminio/${cloudfoundry_system_domain}-cc-packages"
./mc mb "newminio/${cloudfoundry_system_domain}-cc-resources"





echo "Begin Transfering files from minio single node  to minio cluster"

 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-buildpacks" "newminio/${cloudfoundry_system_domain}-cc-buildpacks"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-droplets" "newminio/${cloudfoundry_system_domain}-cc-droplets"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-packages" "newminio/${cloudfoundry_system_domain}-cc-packages"
 ./mc mirror --remove --overwrite "minio/${cloudfoundry_system_domain}-cc-resources" "newminio/${cloudfoundry_system_domain}-cc-resources"
echo "End of transfert"



