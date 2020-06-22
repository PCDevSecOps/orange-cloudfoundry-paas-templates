#!/bin/sh -e

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}


echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

#workaround: skip spruce templating
cp ${BASE_TEMPLATE_DIR}/minio-private-s3.yml $GENERATE_DIR/ 

