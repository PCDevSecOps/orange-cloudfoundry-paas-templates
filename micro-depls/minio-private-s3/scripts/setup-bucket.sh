#!/bin/sh

DEFAULT_BUCKET_LIST="bosh-releases compiled-releases cached-buildpacks stemcells"
BUCKET_LIST=${BUCKET_LIST:-${DEFAULT_BUCKET_LIST}}
#--- Create buckets (or assert they are present)
for a_bucket in $BUCKET_LIST;do
  echo "Creates $a_bucket when missing"
  mc mb minio/"${a_bucket}" --ignore-existing
done
mc ls minio

#--- Enable public download for all buckets

for a_bucket in $BUCKET_LIST;do
  echo "Allow anonymous download for $a_bucket bucket"
  mc policy set download minio/"${a_bucket}"
  mc policy list minio/"$a_bucket"
done
