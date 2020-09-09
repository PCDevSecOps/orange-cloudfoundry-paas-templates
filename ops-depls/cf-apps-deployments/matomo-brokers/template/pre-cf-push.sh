#!/bin/sh

# Setup configurations
# bosh cli version install
bosh_cli_version="2.0.36"
curl -L -s -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64"
chmod 755 /usr/local/bin/bosh

# Setup environment
SECRETS_DIR=${SECRETS_DIR:-.}
#SHARED_SECRETS=${SECRETS_DIR}/../../../shared/secrets.yml

GENERATE_DIR=${GENERATE_DIR:-.}
VERSION=0.6.1
echo "Installing version ${VERSION} of Matomo CF Service"

echo "	- Downloading bits from Github"
mkdir ${GENERATE_DIR}/matomo-brokers
curl -L -s -o ${GENERATE_DIR}/matomo-brokers/matomo-cf-service.jar https://github.com/orange-cloudfoundry/matomo-cf-service/releases/download/v${VERSION}/matomo-cf-service-${VERSION}.jar

# creating orgs and spaces for broker
echo "	- Creating space for the service"
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"
cf bind-security-group cf-ssh-internal "$CF_ORG" "$CF_SPACE" #enable outbound ssh for staging things.  

#creating service instance space
echo "	- Creating space for service instances"
cf create-space matomo-service-instances -o system_domain #system_domain is used to host intranet matamo services.

# creating a mysql database instance for the service
echo -n "Checking if mcfs-db already exists: "
cf s | grep "mcfs-db" > /dev/null
if [ $? -ne 0 ]; then
	echo "creating it"
	cf cs p-mysql 1gb mcfs-db
	if [ $? -ne 0 ]; then
		exit 1
	fi
else
	echo "existing"
fi
echo "Ready for deployment!!"