#!/bin/bash
# admin(recompile-uncomplete-v49-releases): workaround for v50 to recompile some deployment errors with COA 5.1 bosh director pull mode

DEFAULT_SECRETS_PATH=~/bosh/secrets
DEFAULT_TEMPLATES_PATH=~/bosh/template
#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

STEMCELL_OS=${STEMCELL_OS:-"ubuntu-xenial"}
STEMCELL_VERSION=${STEMCELL_VERSION:-"621.89"}
DRY_RUN=${DRY_RUN:-"false"}

export_bosh_releases(){
  root_deployment=$1
  deployment_name=$2
  deployment_releases=$3
  dry_run=$4

  echo "Processing deployment $root_deployment/$deployment_name"
  for release_name_and_version in $deployment_releases;do
    echo "Processing release $release_name_and_version from $root_deployment/$deployment_name"
    if [ "$dry_run" = "true" ]; then
      echo "DRY_RUN - skipping: bosh -e $root_deployment -d $deployment_name export-release --dir=/tmp \"$release_name_and_version\" \"$STEMCELL_OS/$STEMCELL_VERSION\""
      echo "DRY_RUN - skipping: rm /tmp/${release_name_and_version/\//-}-$STEMCELL_OS-$STEMCELL_VERSION*.tgz"
    else
      bosh -e $root_deployment -d $deployment_name export-release --dir=/tmp "$release_name_and_version" "$STEMCELL_OS/$STEMCELL_VERSION"
      rm /tmp/${release_name_and_version/\//-}-$STEMCELL_OS-$STEMCELL_VERSION*.tgz
    fi
  done
}

for root_deployment in micro master coab ops remote-r2 remote-r3;do
  echo "Checking logging status for bosh-$root_deployment"
  logging_status=$(bosh -e $root_deployment configs >/dev/null 2>&1)
  if [ $? -ne 0 ];then
    echo "Logging to bosh-$root_deployment"
    . /usr/local/bin/log-bosh.sh -t $root_deployment
  else
    echo "Already logging into $root_deployment"
  fi
done

echo "Processing bosh-micro"
export_bosh_releases "micro" "concourse" "prometheus/26.3.0 postgres/42 haproxy/10.1.0" $DRY_RUN
export_bosh_releases "micro" "internet-proxy" "squid/1.0.1" $DRY_RUN
export_bosh_releases "micro" "k8s" "helm-kubectl/28" $DRY_RUN

# This is not required as this script should be triggered before
#log-fly
#${TOOLS_PATH}/retrigger-failed-jobs.sh -i micro-depls-bosh-generated

echo "====================================================================================================="
echo "Processing bosh-master"
export_bosh_releases "master" "cloudfoundry-datastores" "prometheus/26.3.0 postgres/42 haproxy/10.1.0" $DRY_RUN
export_bosh_releases "master" "intranet-interco-relay" "squid/1.0.1" $DRY_RUN
export_bosh_releases "master" "cf" "nats/34 capi/1.99.0 cf-networking/2.33.0 cflinuxfs3/0.202.0 garden-runc/1.19.16 silk/2.33.0" $DRY_RUN
export_bosh_releases "master" "prometheus" "prometheus-addons/3.1.1" $DRY_RUN
export_bosh_releases "master" "ops-routing" "nats/34" $DRY_RUN
export_bosh_releases "master" "k8s" "helm-kubectl/28" $DRY_RUN

echo "====================================================================================================="
echo "Processing bosh-coab"
export_bosh_releases "coab" "mongodb" "prometheus-addons/3.1.1" $DRY_RUN
export_bosh_releases "coab" "02-redis-extended" "prometheus/26.3.0 haproxy/10.1.0" $DRY_RUN
export_bosh_releases "coab" "10-k8s-longhorn" "helm-kubectl/28" $DRY_RUN

echo "====================================================================================================="
echo "Processing bosh-ops"
export_bosh_releases "ops" "cf-rabbit-osb" "prometheus/26.3.0 haproxy/10.1.0" $DRY_RUN

echo "====================================================================================================="
for root_deployment in remote-r2 remote-3; do
echo "Processing $root_deployment"
export_bosh_releases "$root_deployment" "00-bootstrap" "prometheus/26.3.0 haproxy/10.1.0" $DRY_RUN
export_bosh_releases "ops" "cf-rabbit" "prometheus/26.3.0" $DRY_RUN




#bosh -e ops deployments --json|jq '.Tables[].Rows[]|"name:"+ .name + " @@@@ releases: "+ .release_s' | grep prometheus|grep haproxy

#BOSH_DEPLOYMENTS=$(bosh deployments --json|jq -r '.Tables[].Rows[].name')
#for deployment_name in $BOSH_DEPLOYMENTS;do
#  echo "Processing deployment $deployment_name"
#  deployment_releases=$(bosh -d $deployment_name deployment --json|jq -r '.Tables[].Rows[].release_s')
#  for release_name_and_version in $deployment_releases;do
#    echo "Processing release $release_name_and_version from $deployment_name"
#    bosh -d $deployment_name export-release --dir=/tmp "$release_name_and_version" "$STEMCELL_OS/$STEMCELL_VERSION"
#    rm /tmp/${release_name_and_version/\//-}-$STEMCELL_OS-$STEMCELL_VERSION*.tgz
#  done
#done
