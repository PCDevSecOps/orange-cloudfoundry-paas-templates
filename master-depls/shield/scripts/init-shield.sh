#!/bin/bash
#===========================================================================
# Init OBOS buckets for shields backups
#===========================================================================

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

getCredhub() {
  credhubGet=$(credhub g -n $2 -j | jq .value -r)
  if [ $? = 0 ] ; then
    eval $1='$(echo "${credhubGet}")'
  else
    printf "\n\n%bERROR : \"$2\" credhub value unknown.%b\n\n" "${RED}" "${STD}"
  fi
}

#--- Log to credhub
flagError=0
flag=$(credhub f > /dev/null 2>&1)
if [ $? != 0 ] ; then
  printf "%bEnter CF LDAP user and password :%b\n" "${REVERSE}${YELLOW}" "${STD}"
  credhub api --server=https://credhub.internal.paas:8844 > /dev/null 2>&1
  credhub login
  if [ $? != 0 ] ; then
    printf "\n%bERROR : Bad LDAP authentication.%b\n\n" "${RED}" "${STD}"
    flagError=1
  fi
fi

if [ "${flagError}" = "0" ] ; then
  getCredhub "SYSTEM_DOMAIN" "/secrets/cloudfoundry_system_domain"

  #--- Configure acces to OBOS V2
  getCredhub "BUCKET_PREFIX" "/secrets/shield_obos_bucket_prefix"
  getCredhub "ACCESS_KEY_ID" "/secrets/shield_obos_access_key_id"
  getCredhub "S3_ACCESS_KEY" "/secrets/shield_obos_secret_access_key"
  mc config host add obosv2 https://storage.orange.com ${ACCESS_KEY_ID} ${S3_ACCESS_KEY} --api s3v2
  if [ $? != 0 ] ; then
    printf "\n%bERROR : OBOS V2 configuration access failed.%b\n\n" "${RED}" "${STD}"
    exit 1
  fi

  #--- Create buckets for OBOS V2 (or assert if they already exists)
  mc mb obosv2/${BUCKET_PREFIX}-bosh-expe --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-bosh-kubo --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-bosh-master --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-bosh-ops --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-bosh-coab --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cassandra-all-db --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-autoscaler-db --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-blobstore --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores-mysql --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores-mysql-network-connectivity --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores-mysql-network-policy --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores-mysql-routing-api --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-cf-datastores-postgres --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-concourse --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-credhub --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-gitlab --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-guardian-uaa --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-guardian-uaa-prod --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-metabase --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-mongo-db --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-mongodb-all-db --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-openldap --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-peripli-sm --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-postgres-all-db --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-p-mysql-etherpad --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-p-mysql-full-backup --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-p-mysql-osb-full-backup --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-rabbitmq --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-rabbitmq37 --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-redis-broker --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-redis-dedicated --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-redis-osb-broker --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-redis-osb-dedicated --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-shield --ignore-existing

  mc mb obosv2/${BUCKET_PREFIX}-${SYSTEM_DOMAIN}-cc-droplets --ignore-existing
  mc mb obosv2/${BUCKET_PREFIX}-${SYSTEM_DOMAIN}-cc-packages --ignore-existing

  printf "\n%bOBOS V2 buckets:%b\n" "${YELLOW}" "${STD}"
  mc ls obosv2
  printf "\n"

  #--- Configure acces to OBOS V4
  getCredhub "BUCKET_PREFIX" "/secrets/backup_bucket_prefix"
  getCredhub "HOST" "/secrets/backup_remote_s3_host"
  getCredhub "ACCESS_KEY_ID" "/secrets/backup_remote_s3_access_key_id"
  getCredhub "ACCESS_KEY" "/secrets/backup_remote_s3_secret_access_key"

  mc config host add obosv4 https://${HOST} ${ACCESS_KEY_ID} ${ACCESS_KEY} --api s3v4
  if [ $? != 0 ] ; then
    printf "\n%bERROR : OBOS V4 configuration access failed.%b\n\n" "${RED}" "${STD}"
    exit 1
  fi

  #--- Create buckets for OBOS V4 (or assert if they already exists)
  mc mb obosv4/${BUCKET_PREFIX}-cassandracoab --ignore-existing
  mc mb obosv4/${BUCKET_PREFIX}-cf-mysqlcoab --ignore-existing
  mc mb obosv4/${BUCKET_PREFIX}-cf-rabbitcoab --ignore-existing
  mc mb obosv4/${BUCKET_PREFIX}-mongodbcoab --ignore-existing
  mc mb obosv4/${BUCKET_PREFIX}-shieldcoab --ignore-existing


  printf "\n%bOBOS V4 buckets:%b\n" "${YELLOW}" "${STD}"
  mc ls obosv4
  printf "\n"
fi
