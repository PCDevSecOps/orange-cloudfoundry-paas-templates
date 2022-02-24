#!/bin/bash
export CONFIG_REPO=$1

GetCredhubValue() {
  PATH_NAME="$1"
  KEY="$2"

  if [ -z "$PATH_NAME" ]; then
    echo "ERROR - Missing name of the credential to retrieve"
    exit 1
  fi
  local value="$(credhub get -q -n "${PATH_NAME}"  2>/dev/null)"
  echo "$value"
}
cat <<EOF >/tmp/jcr-patch.yml
remoteRepositories:
  jfrog-io:
    type: docker
    url: https://releases-docker.jfrog.io/
    proxy: internet-proxy
    enableTokenAuthentication: true
    repoLayout: simple-default
    excludesPattern:
      - orangecloudfoundry/**/*

virtualRepositories:
  docker:
    type: docker
    repositories:
    - docker-via-intranet
    - docker-remote
    - quay-io-via-intranet
    - quay-io-remote
    - k8s-gcr-io
    - suse-docker
    - registry.gitlab.com
    - ghcr-io
    - jfrog-io

EOF
set -e

echo "Getting jcr admin password"
jcr_admin_password=$(GetCredhubValue "/micro-bosh/00-core-connectivity-k8s/jcr_admin_password")
echo "Getting ops domain"
ops_domain=$(GetCredhubValue "/secrets/cloudfoundry_ops_domain")
jcr_hostname="jcr-k8s.$ops_domain"

echo "Checking $jcr_hostname status:"
curl ${AUTH} -sSLfk https://$jcr_hostname/artifactory/api/system/ping

export AUTH="-u admin:${jcr_admin_password}"
if curl ${AUTH} -X PATCH -sSLfk "https://$jcr_hostname/artifactory/api/system/configuration" -H "Content-Type:application/yaml" -T /tmp/jcr-patch.yml; then
  echo "Done - $0"
else
  echo "fail to load patch JCR config - $0"
  exit 1
fi
