#!/bin/sh -x
echo "creating postgresql-docker-test-app application"

echo "Copying source code"
cp -r ${CUSTOM_SCRIPT_DIR}/* ${GENERATE_DIR}
cp -r ${CUSTOM_SCRIPT_DIR}/* ./

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf target -s $CF_SPACE -o $CF_ORG

service_name="postgresql-docker-test-app-service"
echo "checks ${service_name} service name"
cf s | grep $service_name

if [ $? -ne 0 ]; then
    echo "creating ${service_name}"
	cf cs postgres-cluster Default $service_name
	if [ $? -ne 0 ]; then
		echo "Error during create service"
		exit 1
	fi
else
    echo "service ${service_name} found"
fi

echo ${GENERATE_DIR}
cd ${GENERATE_DIR}
ls ${GENERATE_DIR}