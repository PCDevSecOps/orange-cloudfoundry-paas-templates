#!/bin/sh

# Setup configurations
# bosh cli version install
BOSH_CLI_VERSION="6.4.0"
curl -L -s -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64"
chmod 755 /usr/local/bin/bosh

# Setup environment
SECRETS_DIR=${SECRETS_DIR:-.}
#SHARED_SECRETS=${SECRETS_DIR}/../../../shared/secrets.yml
S3_HOST=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/db_dumper/storage/host)
S3_ACCESS_KEY_ID=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/db_dumper/storage/access_key_id)
S3_SECRET_ACCESS_KEY=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/db_dumper/storage/secret_access_key)
S3_BUCKET=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/db_dumper/storage/bucket)

GENERATE_DIR=${GENERATE_DIR:-.}


echo "downloading db dumper service"
mkdir ${GENERATE_DIR}/db-dumper
curl -L -s -o ${GENERATE_DIR}/db-dumper/db-dumper-service.zip https://github.com/orange-cloudfoundry/db-dumper-service/releases/download/v1.3.2/db-dumper-service.zip

#Unziping db dumper release
cd ${GENERATE_DIR}/db-dumper
unzip db-dumper-service.zip

rm db-dumper-service.zip

cd db-dumper-service
cd target

cp db-dumper-service-1.3.2.war ${GENERATE_DIR}/db-dumper-service-1.3.2.war

# creating orgs and spaces
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

cf bind-security-group wide-open $CF_ORG $CF_SPACE

# creating an mysql database instances
echo "Checking if the mysql-db-dumper-service already exist"
cf s | grep "mysql-db-dumper-service" > /dev/null

if [ $? -ne 0 ]; then
    echo "Creating mysql-db-dumper-service"
    cf cs p-mysql 1gb mysql-db-dumper-service
    if [ $? -ne 0 ]; then
            exit 1
    fi
else
 echo "Service mysql-db-dumper-service found"
fi


#user provided service
# export credentials information to a json file
echo  {\""uri\"": \""s3://${S3_ACCESS_KEY_ID}:${S3_SECRET_ACCESS_KEY}@${S3_HOST}/${S3_BUCKET}\""} > s3.json



# if the user provided service not exist
# count the number of service having the same name as the use provided service ,
# if the number is zero then there is no user provided service having the same name as s3-storage

echo "Checking if the s3-storage user provided service already exist"
cf s | grep "s3-storage" > /dev/null

if [ $? -ne 0 ];
then
    echo "Creating s3-storage user provided service "
    cf create-user-provided-service s3-storage -p s3.json
    if [ $? -ne 0 ]; then
            exit 1
    fi
else
    echo "Updating s3-storage user provided service "
    cf update-user-provided-service s3-storage -p s3.json
    if [ $? -ne 0 ]; then
            exit 1
    fi
fi







