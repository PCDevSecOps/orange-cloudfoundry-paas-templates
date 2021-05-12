#!/bin/bash
#===========================================================================
# Switch gitlab repositories to k8s
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Check target status
display "Phase 0: Check vip endpoints after upgrade"
checkPort "192.168.116.19" "443"    #--- ops traffic
checkPort "192.168.116.19" "389"    #--- ldap
checkPort "192.168.116.19" "9000"   #--- minio
checkPort "192.168.116.15" "3128"   #--- internet proxy
checkPort "192.168.116.17" "3129"   #--- intranet proxy
checkAccess "200" "https" "jcr-k8s.${OPS_DOMAIN}" "192.168.116.19"                #--- 00-core-connectivity endpoint
checkAccess "302" "https" "gitlab-gitlab-k8s.${OPS_DOMAIN}" "192.168.116.19"      #--- 01-ci-k8s endpoint
checkAccess "200" "https" "rancher-micro.${OPS_DOMAIN}" "192.168.116.19"          #--- 00-gitops-management endpoint
checkAccess "200" "https" "elpaaso-concourse.${OPS_DOMAIN}" "192.168.116.19"      #--- gorouter ops legacy endpoint
checkAccess "403" "http" "private-s3.internal.paas:9000" "192.168.116.19:9000"    #--- gorouter internal legacy endpoint

display "Phase 1: Check traefik switch to k8s"
checkProfile "51-switch-to-k8s-traefik"
checkAccess "200" "https" "jcr-k8s.${OPS_DOMAIN}"             #--- 00-core-connectivity legacy access
checkAccess "302" "https" "gitlab-gitlab-k8s.${OPS_DOMAIN}"   #--- 01-ci-k8s legacy access
checkAccess "200" "https" "rancher-micro.${OPS_DOMAIN}"       #--- 00-gitops-management legacy access
checkAccess "200" "https" "elpaaso-concourse.${OPS_DOMAIN}"   #--- 01-ci-k8s legacy access
checkAccess "403" "http" "private-s3.internal.paas:9000"      #--- gorouter internal legacy endpoint

display "Phase 2: Check internet-proxy, intranet-proxy and openldap switch to k8s"
checkProfile "51-switch-internet-proxy"
checkProfile "51-switch-intranet-proxy"
checkProfile "51-switch-to-k8s-openldap"
checkHost "system-internet-http-proxy.internal.paas" "192.168.116.15" "3128"
checkHost "intranet-http-proxy.internal.paas" "192.168.116.17" "3129"
checkHost "elpaaso-ldap.internal.paas" "192.168.116.19" "389"

export https_proxy="http://system-internet-http-proxy.internal.paas:3128"
checkAccess "200" "https" "www.google.com"                    #--- Check internet access from internet-proxy
export https_proxy="http://intranet-http-proxy.internal.paas:3129"
checkAccess "302" "https" "gitlab.tech.orange"                #--- Check intranet access from intranet-proxy
unset https_proxy
checkAccess "000" "ldap" "elpaaso-ldap.internal.paas:389"

display "Phase 3: Check minio switch to k8s"
checkProfile "51-switch-to-k8s-minio"
checkPort "192.168.116.50" "9000" "disable"                         #--- Check bosh minio disable
checkAccess "403" "http" "private-s3.internal.paas:9000"            #--- Legacy gorouter access

BUCKETS_LIST="bosh-releases
cached-buildpacks
compiled-releases
stemcells"
checkBucket

display "Phase 4: Check jcr switch to k8s"
checkProfile "51-switch-to-k8s-jcr-for-docker-k3s"
checkSecretsFiles "jcr.${OPS_DOMAIN}"             #--- Check if old fqdn (must be jcr-k8s.<ops-domain>)

DOCKER_REGISTRY_URL="$(getValue "/secrets/coa/config/docker-registry-url" ${SHARED_SECRETS})"
CONCOURSE_PROPERTIES="$(credhub f | grep "docker-registry-url" | grep "concourse-micro" | awk '{print $3}')"

for propertie in ${CONCOURSE_PROPERTIES} ; do
  flag="$(echo "${propertie}" | grep "main/init-upgrade-pipeline")"
  if [ "${flag}" = "" ] ; then
    checkCredhubValue "${propertie}" "${DOCKER_REGISTRY_URL}"
  fi
done

display "Phase 5: Check gitlab switch to k8s"
checkSecretsFiles "elpaaso-gitlab.${OPS_DOMAIN}"    #--- Check if old fqdn (must be gitlab-gitlab-k8s.<ops-domain>)

printf "\n"