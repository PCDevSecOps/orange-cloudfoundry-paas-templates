#!/bin/sh
#https://github.com/pwm-project/pwm
#https://www.pwm-project.org/artifacts/pwm
echo "creating pwm application"
app_name=pwm

apk add --update zip

echo "downloading pwm binary"
curl http://pwm-bucket.s3.amazonaws.com/pwm-1.8.0-SNAPSHOT.war -L -s -o pwm-1.8.0-SNAPSHOT.war
mv pwm-1.8.0-SNAPSHOT.war ${GENERATE_DIR}/pwm.war

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG

cf bind-security-group ldap $CF_ORG --space  $CF_SPACE
cf bind-security-group mail-fed $CF_ORG --space $CF_SPACE

cf target -s $CF_SPACE -o $CF_ORG

service_name="mysql-$app_name"
echo "checks ${service_name}"
cf s | grep $service_name > /dev/null

if [ $? -ne 0 ]; then
    echo "creating ${service_name}"
	cf cs p-mysql 1gb $service_name
	if [ $? -ne 0 ]; then
		exit 1
	fi
else
    echo "service ${service_name} found"
fi

if [ -f ${SECRETS_DIR}/PwmConfiguration.xml ]; then
    echo "updating pwm config files"
    DEST_DIR=${GENERATE_DIR}
    mkdir -p ${DEST_DIR}
    cp $SECRETS_DIR/PwmConfiguration.xml ${DEST_DIR}/PwmConfiguration.xml
    cd ${GENERATE_DIR}
    zip -u pwm.war PwmConfiguration.xml
else
    echo "no pwm config file detected. Skipping"
fi
