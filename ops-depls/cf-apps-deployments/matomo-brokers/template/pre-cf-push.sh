#!/bin/sh

# Matomo service integrated
VERSION=0.9.0

TPLDIR=$(dirname "$0")
# Setup configurations
# bosh cli version install
BOSH_CLI_VERSION="6.4.0"
curl -L -s -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64"
chmod 755 /usr/local/bin/bosh

echo "java install"
#install openjdk
export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
export PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
export JAVA_ALPINE_VERSION=8.252.09-r0
set -x && apk add --no-cache openjdk8="$JAVA_ALPINE_VERSION"
echo "maven install"
#install maven
export PATH=$PATH:/usr/share/java/maven-3/bin
export MAVEN_ALPINE_VERSION=3.6.0-r0
set -x && apk add --no-cache maven="$MAVEN_ALPINE_VERSION"

# Setup environment
SECRETS_DIR=${SECRETS_DIR:-.}
#SHARED_SECRETS=${SECRETS_DIR}/../../../shared/secrets.yml

GENERATE_DIR=${GENERATE_DIR:-.}
echo "Installing version ${VERSION} of Matomo CF Service"

echo "	- Downloading bits from Github"
mkdir ${GENERATE_DIR}/matomo-brokers
curl -L -s -o ${GENERATE_DIR}/matomo-brokers/matomo-cf-service.jar https://github.com/orange-cloudfoundry/matomo-cf-service/releases/download/v${VERSION}/matomo-cf-service-${VERSION}.jar
curl -L -s -o ${GENERATE_DIR}/matomo-brokers/matomo-cf-service.zip https://github.com/orange-cloudfoundry/matomo-cf-service/archive/v${VERSION}.zip
unzip -q ${GENERATE_DIR}/matomo-brokers/matomo-cf-service.zip -d ${GENERATE_DIR}/matomo-brokers
mv ${GENERATE_DIR}/matomo-brokers/matomo-cf-service-${VERSION} ${GENERATE_DIR}/matomo-brokers/matomo-cf-service
cp ${TPLDIR}/default-release.txt ${GENERATE_DIR}/matomo-brokers/matomo-cf-service
cp ${TPLDIR}/releases.txt ${GENERATE_DIR}/matomo-brokers/matomo-cf-service
export MAVEN_OPTS="-Dhttp.proxyHost=system-internet-http-proxy.internal.paas -Dhttp.proxyPort=3128 -Dhttps.proxyHost=system-internet-http-proxy.internal.paas -Dhttps.proxyPort=3128"
(cd ${GENERATE_DIR}/matomo-brokers/matomo-cf-service; mvn -Dmaven.test.skip=true install)
cp ${GENERATE_DIR}/matomo-brokers/matomo-cf-service/target/matomo-cf-service-${VERSION}.jar ${GENERATE_DIR}/matomo-brokers/matomo-cf-service.jar

# creating orgs and spaces for broker
echo "	- Creating space for the service in $CF_ORG organization"
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"
cf bind-security-group cf-ssh-internal "$CF_ORG" "$CF_SPACE" #enable outbound ssh for staging things.  

# creating service instances space
echo "	- Creating space for service instances in $CF_ORG organization"
cf create-space matomo-service-instances -o "$CF_ORG" # Orange is used to host intranet matamo service instances.

# creating a mysql database instance for the service
echo -n "Creating mcfs-db: "
cf s | grep "mcfs-db" > /dev/null
if [ $? -ne 0 ]; then
  echo "doing it"
  cf cs mariadb-shared 1gb mcfs-db
  if [ $? -ne 0 ]; then
    exit 1
  fi
else
  echo "already done"
fi

# creating a smtp access for the service
echo -n "Creating mcfs-smtp: "
cf s | grep "mcfs-smtp" > /dev/null
if [ $? -ne 0 ]; then
  echo "doing it"
  cf cs o-smtp orange-mail-fed-plan mcfs-smtp
  if [ $? -ne 0 ]; then
    exit 1
  fi
else
  echo "already done"
fi

echo "Ready for deployment!!"