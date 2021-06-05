#!/bin/bash
#===========================================================================
# Configure parameters for bootstrap process
# $1 : Configuration step
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script parameters
COA_CONFIG_DIR="${SECRETS_REPO_DIR}/coa/config"
CREDHUB_SECRETS_FILE="${SECRETS_MICRO_DEPLS_DIR}/credhub-ha/secrets/secrets.yml"
DNS_RECURSOR_SECRETS_FILE="${SECRETS_MICRO_DEPLS_DIR}/dns-recursor/secrets/secrets.yml"

#--- Check prerequisites
verifyDirectory "${COA_CONFIG_DIR}"
verifyDirectory "${COA_REPO_DIR}"

if [ $1 != 1 ] ; then
  verifyFile "${SHARED_SECRETS}"
fi
verifyFile "${CREDHUB_SECRETS_FILE}"
verifyFile "${DNS_RECURSOR_SECRETS_FILE}"
verifyFile "${COA_CONFIG_DIR}/credentials-auto-init.yml"
verifyFile "${COA_CONFIG_DIR}/credentials-git-config.yml"
verifyFile "${COA_CONFIG_DIR}/credentials-iaas-specific.yml"
verifyFile "${COA_CONFIG_DIR}/credentials-micro-depls-bosh-pipeline.yml"
verifyFile "${COA_CONFIG_DIR}/credentials-s3-br.yml"

disableOperator() {
  enabled_file="$1"
  disabled_file=$(echo "$1" | sed -e "s+-operators\.yml$+-operators-disabled\.yml+")
  if [ -f ${enabled_file} ] ; then
    mv ${enabled_file} ${disabled_file}
  fi
}

enableOperator() {
  enabled_file="$1"
  disabled_file=$(echo "$1" | sed -e "s+-operators\.yml$+-operators-disabled\.yml+")
  if [ -f ${disabled_file} ] ; then
    mv ${disabled_file} ${enabled_file}
  fi
}

#===========================================================================
# Configuration steps
#===========================================================================

#--- Initial configuration from bootstrap file
Step_1() {
  #--- Parameters
  TEMPLATE_SECRETS_FILE="${INCEPTION_BOOTSTRAP_DIR}/template/${IAAS_TYPE}/tpl-secrets.yml"

  #--- Check prerequisites
  if [ -f ${SHARED_SECRETS} ] ; then
    display "ERROR" "Secrets file \"${SHARED_SECRETS}\" already exists. Delete it before executing this script"
  fi

  #--- Generate initial bosh CA cert, set it in shared/secrets.yml file and store private and ca in credentials files
  display "INFO" "Create bosh internal CA cert"
  createDir "$(dirname ${INTERNAL_CA_KEY})"
  createDir "$(dirname ${INTERNAL_CA2_KEY})"
  bosh int ${TEMPLATE_CERT_FILE} --vars-store=${MICRO_BOSH_CREDENTIALS}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /default_ca/private_key > ${INTERNAL_CA_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /default_ca/ca > ${INTERNAL_CA_CERT}

  #--- Update CA cert end date (bosh create certs with 1 year expiration limit)
  display "INFO" "Change InternalCA cert expiration date"
  EXPIRY_DAYS=3650
  CSR_CONF_FILE="/tmp/cert.conf"
  CSR_FILE="/tmp/cert.csr"

  #--- Generate CSR file from old ca cert
  openssl x509 -x509toreq -in ${INTERNAL_CA_CERT} -signkey ${INTERNAL_CA_KEY} -out ${CSR_FILE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "CSR generation failed"
  fi

  #--- Complete generated CSR with extensions
  serialNumber=$(openssl x509 -in ${INTERNAL_CA_CERT} -serial -noout | cut -f2 -d=)
  printf "[ v3_ca ]\nkeyUsage= critical,keyCertSign,cRLSign\nbasicConstraints= critical,CA:TRUE\n\n" > ${CSR_CONF_FILE}

  #--- Regenerate cert
  openssl x509 -req -days ${EXPIRY_DAYS} -in ${CSR_FILE} -set_serial 0x${serialNumber} -signkey ${INTERNAL_CA_KEY} -out ${INTERNAL_CA_CERT} -extfile ${CSR_CONF_FILE} -extensions v3_ca > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Renew InternalCA cert file failed"
  fi

  #--- Copy cert and key in internalCA2 directory
  cp ${INTERNAL_CA_KEY} ${INTERNAL_CA2_KEY} > /dev/null 2>&1
  cp ${INTERNAL_CA_CERT} ${INTERNAL_CA2_CERT} > /dev/null 2>&1

  #--- Display new enddate
  openssl x509 -in ${INTERNAL_CA_CERT} -enddate -noout
  rm -f ${CSR_FILE} ${CSR_CONF_FILE} > /dev/null 2>&1

  #--- Initialize shared secrets file from template
  display "INFO" "Initialize shared secrets file"
  createDir "$(dirname ${SHARED_SECRETS})"
  cp ${TEMPLATE_SECRETS_FILE} ${SHARED_SECRETS}

  display "INFO" "Update site name and type"
  updateYaml ${SHARED_SECRETS} secrets.site $(getValue ${BOOTSTRAP_VARS_FILE} /site_name)
  updateYaml ${SHARED_SECRETS} secrets.site_type $(getValue ${BOOTSTRAP_VARS_FILE} /site_type)

  display "INFO" "Set passwords"
  BOSH_ADMIN_PASSWORD=$(setPassword)
  VCAP_PASSWORD=$(setPassword)
  VCAP_PASSWORD_SHA512=$(mkpasswd -s -m sha-512 ${VCAP_PASSWORD})
  updateYaml ${SHARED_SECRETS} secrets.bosh.admin.password ${BOSH_ADMIN_PASSWORD}
  updateYaml ${SHARED_SECRETS} secrets.bosh.root.decoded_password ${VCAP_PASSWORD}
  updateYaml ${SHARED_SECRETS} secrets.bosh.root.password ${VCAP_PASSWORD_SHA512}
  updateYaml ${SHARED_SECRETS} secrets.bosh_credhub_secrets "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.ldap.root.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.p-mysql.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.prometheus.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.admin_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.ccdb_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.diegodb_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.firehose_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.nats_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.uaadb_password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.service_brokers.o-intranet-proxy-access.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.service_brokers.coa-cf-mysql-broker.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.service_brokers.coa-mongodb-broker.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.service_brokers.coa-redis-broker.password "$(setPassword)"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.service_brokers.coa-cf-rabbit-broker.password "$(setPassword)"

  display "INFO" "Update vsphere credentials"
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_ip $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_ip)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_user $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_user)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_password $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_password)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_dc $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_dc)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_cluster $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_cluster)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_ds $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_ds)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_resource_pool $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_resource_pool)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_disks $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_disks)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_vms $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_vms)
  updateYaml ${SHARED_SECRETS} secrets.vsphere.vcenter_templates $(getValue ${BOOTSTRAP_VARS_FILE} /vcenter_templates)

  display "INFO" "Update networks names"
  updateYaml ${SHARED_SECRETS} secrets.networks.micro-bosh $(getValue ${BOOTSTRAP_VARS_FILE} /networks/micro_bosh)
  updateYaml ${SHARED_SECRETS} secrets.networks.compilation $(getValue ${BOOTSTRAP_VARS_FILE} /networks/compilation)
  updateYaml ${SHARED_SECRETS} secrets.networks.compilation-dedicated $(getValue ${BOOTSTRAP_VARS_FILE} /networks/compilation-dedicated)
  updateYaml ${SHARED_SECRETS} secrets.networks.net-bosh-2 $(getValue ${BOOTSTRAP_VARS_FILE} /networks/micro-depls)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf_net_exchange $(getValue ${BOOTSTRAP_VARS_FILE} /networks/master-depls)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-osb-control-plane $(getValue ${BOOTSTRAP_VARS_FILE} /networks/osb_control_plane)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-osb-data-plane-shared-pub $(getValue ${BOOTSTRAP_VARS_FILE} /networks/osb_data_plane_shared_pub)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-osb-data-plane-shared-pub2 $(getValue ${BOOTSTRAP_VARS_FILE} /networks/osb_data_plane_shared_pub2)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-osb-data-plane-shared-priv $(getValue ${BOOTSTRAP_VARS_FILE} /networks/osb_data_plane_shared_priv)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-osb-data-plane-dedicated-priv $(getValue ${BOOTSTRAP_VARS_FILE} /networks/osb_data_plane_dedicated_priv)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-cf $(getValue ${BOOTSTRAP_VARS_FILE} /networks/net_cf)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-cfcr-micro $(getValue ${BOOTSTRAP_VARS_FILE} /networks/k8s_micro)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-cfcr-master $(getValue ${BOOTSTRAP_VARS_FILE} /networks/k8s_master)
  updateYaml ${SHARED_SECRETS} secrets.networks.tf-net-kubo $(getValue ${BOOTSTRAP_VARS_FILE} /networks/k8s_services)

  display "INFO" "Update intranet interco network"
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.net_id $(getValue ${BOOTSTRAP_VARS_FILE} /networks/intranet_interco)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.range $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/range)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.gateway $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/gateway)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.api $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/api_ip)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.apps $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/apps_ip)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.ops $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/ops_ip)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.to_internet_proxy $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/to_internet_proxy_ip)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.to_intranet $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/to_intranet_proxy_ip)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.dns_recursor_1 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/dns_recursor_1)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.dns_recursor_2 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/dns_recursor_2)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_ips.concourse_public_ip $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/concourse_public_ip)

  display "INFO" "Update intranet-1 interco network"
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.cf_org $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco_1/cf_org)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.intranet_dns_1 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco_1/intranet_dns_1)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.intranet_dns_2 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco_1/intranet_dns_2)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.ntp_server_1 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco_1/ntp_server_1)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.ntp_server_2 $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco_1/ntp_server_2)

  display "INFO" "Update osb interco network"
  updateYaml ${SHARED_SECRETS} secrets.osb_interco.net_id $(getValue ${BOOTSTRAP_VARS_FILE} /networks/intranet_interco)
  updateYaml ${SHARED_SECRETS} secrets.osb_interco.range $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/range)
  updateYaml ${SHARED_SECRETS} secrets.osb_interco.gateway $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/gateway)
  updateYaml ${SHARED_SECRETS} secrets.osb_interco.osb $(getValue ${BOOTSTRAP_VARS_FILE} /intranet_interco/osb_ip)

  display "INFO" "Update osb data plane dedicated public network"
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_dedicated_public.net_id $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_dedicated_public/net_id)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_dedicated_public.range $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_dedicated_public/range)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_dedicated_public.gateway $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_dedicated_public/gateway)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_dedicated_public.reserved_dhcp $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_dedicated_public/reserved_dhcp)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_dedicated_public.static $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_dedicated_public/static)

  display "INFO" "Update osb data plane shared public network"
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.net_id $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/net_id)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.range $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/range)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.gateway $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/gateway)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.reserved_dhcp $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/reserved_dhcp)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.reserved_vrrp $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/reserved_vrrp)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public.static $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public/static)

  display "INFO" "Update osb data plane shared 2 public network"
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.net_id $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/net_id)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.range $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/range)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.gateway $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/gateway)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.reserved_dhcp $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/reserved_dhcp)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.reserved_vrrp $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/reserved_vrrp)
  updateYaml ${SHARED_SECRETS} secrets.osb_data_plane_shared_public2.static $(getValue ${BOOTSTRAP_VARS_FILE} /osb_data_plane_shared_public2/static)

  display "INFO" "Update pki domains"
  updateYaml ${SHARED_SECRETS} secrets.cloudfoundry.system_domain $(getValue ${BOOTSTRAP_VARS_FILE} /api_domain)
  updateYaml ${SHARED_SECRETS} secrets.intranet_interco_1.apps_domain $(getValue ${BOOTSTRAP_VARS_FILE} /apps_domain)
  updateYaml ${SHARED_SECRETS} secrets.ops_interco.ops_domain $(getValue ${BOOTSTRAP_VARS_FILE} /ops_domain)
  updateYaml ${SHARED_SECRETS} secrets.osb_interco.osb_domain $(getValue ${BOOTSTRAP_VARS_FILE} /osb_domain)

  display "INFO" "Update S3 backup credentials"
  updateYaml ${SHARED_SECRETS} secrets.backup.bucket_prefix $(getValue ${BOOTSTRAP_VARS_FILE} /backup/bucket_prefix)
  updateYaml ${SHARED_SECRETS} secrets.backup.local_s3.host $(getValue ${BOOTSTRAP_VARS_FILE} /backup/local_s3/host)
  updateYaml ${SHARED_SECRETS} secrets.backup.local_s3.access_key_id $(getValue ${BOOTSTRAP_VARS_FILE} /backup/local_s3/access_key_id)
  updateYaml ${SHARED_SECRETS} secrets.backup.local_s3.secret_access_key $(getValue ${BOOTSTRAP_VARS_FILE} /backup/local_s3/secret_access_key)
  updateYaml ${SHARED_SECRETS} secrets.backup.remote_s3.host $(getValue ${BOOTSTRAP_VARS_FILE} /backup/remote_s3/host)
  updateYaml ${SHARED_SECRETS} secrets.backup.remote_s3.access_key_id $(getValue ${BOOTSTRAP_VARS_FILE} /backup/remote_s3/access_key_id)
  updateYaml ${SHARED_SECRETS} secrets.backup.remote_s3.secret_access_key $(getValue ${BOOTSTRAP_VARS_FILE} /backup/remote_s3/secret_access_key)
  updateYaml ${SHARED_SECRETS} secrets.backup.remote_s3.secret_access_key $(getValue ${BOOTSTRAP_VARS_FILE} /backup/remote_s3/secret_access_key)
  updateYaml ${SHARED_SECRETS} secrets.backup.remote_s3.signature_version $(getValue ${BOOTSTRAP_VARS_FILE} /backup/remote_s3/signature_version)

  display "INFO" "Update SMTP mail"
  updateYaml ${SHARED_SECRETS} secrets.smtp.from $(getValue ${BOOTSTRAP_VARS_FILE} /smtp_mail)
  updateYaml ${SHARED_SECRETS} secrets.smtp.to_ops $(getValue ${BOOTSTRAP_VARS_FILE} /smtp_mail)

  display "INFO" "Update dns/ntp credentials"
  IAAS_DNS_1="$(getValue ${BOOTSTRAP_VARS_FILE} /target_dns_recursor_1)"
  IAAS_DNS_2="$(getValue ${BOOTSTRAP_VARS_FILE} /target_dns_recursor_2)"
  IAAS_NTP_1="$(getValue ${BOOTSTRAP_VARS_FILE} /target_ntp_server_1)"
  IAAS_NTP_2="$(getValue ${BOOTSTRAP_VARS_FILE} /target_ntp_server_2)"
  sed -i "s+iaas_dns: .*+iaas_dns: [${IAAS_DNS_1},${IAAS_DNS_2}]+" ${SHARED_SECRETS}
  updateYaml ${DNS_RECURSOR_SECRETS_FILE} secrets.target_dns_recursor_1 ${IAAS_DNS_1}
  updateYaml ${DNS_RECURSOR_SECRETS_FILE} secrets.target_dns_recursor_2 ${IAAS_DNS_2}
  updateYaml ${DNS_RECURSOR_SECRETS_FILE} secrets.target_ntp_server_1 ${IAAS_NTP_1}
  updateYaml ${DNS_RECURSOR_SECRETS_FILE} secrets.target_ntp_server_2 ${IAAS_NTP_2}

  display "INFO" "Update credhub credentials"
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.database-admin $(setPassword)
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.uaa-users-admin $(setPassword)
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.uaa-admin $(setPassword)
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.uaa-login $(setPassword)
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.credhub-encryption-password $(setPassword)
  updateYaml ${CREDHUB_SECRETS_FILE} secrets.uaa_encryption_key_1 $(setPassword)

  display "INFO" "Update coa credentials"
  INCEPTION_PRIVATE_IP="$(getValue ${BOOTSTRAP_VARS_FILE} /micro_bosh/inception_ip)"
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml secrets-uri git://${INCEPTION_PRIVATE_IP}/secrets
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml paas-templates-uri git://${INCEPTION_PRIVATE_IP}/template
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml cf-ops-automation-uri git://${INCEPTION_PRIVATE_IP}/coa
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml cf-ops-automation-tag-filter v$(getValue ${BOOTSTRAP_VARS_FILE} /coa_version)

  updateYaml ${COA_CONFIG_DIR}/credentials-micro-depls-bosh-pipeline.yml bosh-password ${BOSH_ADMIN_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-master-depls-bosh-pipeline.yml bosh-password ${BOSH_ADMIN_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-ops-depls-bosh-pipeline.yml bosh-password ${BOSH_ADMIN_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-coab-depls-bosh-pipeline.yml bosh-password ${BOSH_ADMIN_PASSWORD}

  updateYaml ${COA_CONFIG_DIR}/credentials-iaas-specific.yml iaas-type $(getValue ${BOOTSTRAP_VARS_FILE} /iaas_type)
  updateYaml ${COA_CONFIG_DIR}/credentials-iaas-specific.yml stemcell-main-name $(echo "$(getValue ${BOOTSTRAP_VARS_FILE} /stemcell_name)" | sed -e "s+bosh-++")

  PROXY_HOST=$(getValue ${SHARED_SECRETS} /secrets/proxy/intranet_host)
  PROXY_PORT=$(getValue ${SHARED_SECRETS} /secrets/proxy/intranet_port)
  updateYaml ${COA_CONFIG_DIR}/credentials-slack-config.yml slack-proxy http://${PROXY_HOST}:${PROXY_PORT}
  updateYaml ${COA_CONFIG_DIR}/credentials-slack-config.yml slack-webhook $(getValue ${BOOTSTRAP_VARS_FILE} /slack-webhook)
  updateYaml ${COA_CONFIG_DIR}/credentials-slack-config.yml slack-channel $(getValue ${BOOTSTRAP_VARS_FILE} /slack-channel)

  display "INFO" "Set coa in online mode and disable precompile mode"
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.boshreleases false
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.stemcells false
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.docker-images false
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml precompile-mode: false

  commitGit "secrets" "set_initial_credentials"
}

#--- Configuration step after micro-bosh creation
Step_2.1() {
  #--- Set micro-bosh bosh-dns keys and certs
  BOSH_DNS_CA_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_api_tls_ca.crt"
  BOSH_DNS_CA_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_api_tls_ca.key"
  BOSH_DNS_SERVER_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_api_server_tls.key"
  BOSH_DNS_SERVER_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_api_server_tls.crt"
  BOSH_DNS_CLIENT_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_api_client_tls.key"
  BOSH_DNS_CLIENT_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_api_client_tls.crt"

  BOSH_DNS_HC_CA_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_tls_ca.crt"
  BOSH_DNS_HC_CA_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_tls_ca.key"
  BOSH_DNS_HC_SERVER_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_server_tls.key"
  BOSH_DNS_HC_SERVER_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_server_tls.crt"
  BOSH_DNS_HC_CLIENT_KEY="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_client_tls.key"
  BOSH_DNS_HC_CLIENT_CERT="${ROOT_CERT_DIR}/bosh-dns/dns_healthcheck_client_tls.crt"

  createDir "$(dirname ${BOSH_DNS_CA_CERT})"
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_tls_ca/ca > ${BOSH_DNS_CA_CERT}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_tls_ca/private_key > ${BOSH_DNS_CA_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_server_tls/private_key > ${BOSH_DNS_SERVER_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_server_tls/certificate > ${BOSH_DNS_SERVER_CERT}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_client_tls/private_key > ${BOSH_DNS_CLIENT_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_api_client_tls/certificate > ${BOSH_DNS_CLIENT_CERT}

  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_tls_ca/ca > ${BOSH_DNS_HC_CA_CERT}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_tls_ca/private_key > ${BOSH_DNS_HC_CA_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_server_tls/private_key > ${BOSH_DNS_HC_SERVER_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_server_tls/certificate > ${BOSH_DNS_HC_SERVER_CERT}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_client_tls/private_key > ${BOSH_DNS_HC_CLIENT_KEY}
  bosh int ${MICRO_BOSH_CREDENTIALS} --path /~1dns_healthcheck_client_tls/certificate > ${BOSH_DNS_HC_CLIENT_CERT}

  commitGit "secrets" "set_dns_certs"

  #--- Log to credhub
  export CREDHUB_SERVER="https://credhub.internal.paas:8844"
  export CREDHUB_CLIENT="director_to_credhub"
  export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
  export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)
  credhub api > /dev/null 2>&1
  credhub login > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Credhub login failed"
  fi

  #--- Set concourse teams properties
  display "INFO" "Set concourse teams properties to credhub"
  TEAMS="main micro-depls master-depls ops-depls coab-depls cloudflare-depls remote-r2-depls remote-r3-depls utils"
  for team in ${TEAMS} ; do
    credhub d -n /concourse-micro/${team}/docker-registry-url > /dev/null 2>&1
    credhub s -t value -n /concourse-micro/${team}/docker-registry-url -v "registry.hub.docker.com" > /dev/null 2>&1
    if [ $? != 0 ] ; then
      display "ERROR" "Set propertie to credhub failed"
    fi
  done
}

#--- Configuration step after micro-depls deployments in "bootstrap mode"
Step_2.2() {
  #--- Log to credhub
  export CREDHUB_SERVER="https://credhub.internal.paas:8844"
  export CREDHUB_CLIENT="director_to_credhub"
  export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
  export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)
  credhub api > /dev/null 2>&1
  credhub login > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Credhub login failed"
  fi

  display "INFO" "Set IAAS type to credhub"
  credhub s -t value -n /secrets/iaas_type -v ${IAAS_TYPE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set site type to credhub"
  credhub s -t value -n /secrets/site_type -v $(getValue ${SHARED_SECRETS} /secrets/site_type) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set system domain to credhub"
  credhub s -t value -n /secrets/cloudfoundry_system_domain -v $(getValue ${SHARED_SECRETS} /secrets/cloudfoundry/system_domain) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set apps domain to credhub"
  credhub s -t value -n /secrets/cloudfoundry_apps_domain -v $(getValue ${SHARED_SECRETS} /secrets/intranet_interco_1/apps_domain) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set ops domain to credhub"
  credhub s -t value -n /secrets/cloudfoundry_ops_domain -v $(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set osb domain to credhub"
  credhub s -t value -n /secrets/cloudfoundry_osb_domain -v $(getValue ${SHARED_SECRETS} /secrets/osb_interco/osb_domain) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set internalCA to credhub"
  credhub s -t certificate -n /internalCA -r ${INTERNAL_CA_CERT} -c ${INTERNAL_CA_CERT} -p ${INTERNAL_CA_KEY} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi
  credhub s -t certificate -n /internalCA2 -r ${INTERNAL_CA_CERT} -c ${INTERNAL_CA_CERT} -p ${INTERNAL_CA_KEY} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set intranet CA certs to credhub"
  credhub s -t value -n /secrets/certs/intranet-ca -v "$(cat ${INTRANET_CA_CERTS})" > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set nats password for minio to credhub"
  credhub s -t password -n /bosh-master/ops-routing/nats_password -w $(setPassword) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  display "INFO" "Set crehub admin password to credhub"
  credhub s -t value -n /micro-bosh/credhub-ha/credhub_uaa_admin_client_secret -v $(getValue ${CREDHUB_SECRETS_FILE} /secrets/uaa-users-admin) > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Set propertie to credhub failed"
  fi

  #--- Set properties for coa pipelines
  display "INFO" "Update coa config"
  CONCOURSE_USER=$(getCredhubValue "/micro-bosh/concourse/local_user" "username")
  CONCOURSE_PASSWORD=$(getCredhubValue "/micro-bosh/concourse/local_user" "password")
  CONCOURSE_ENDPOINT="http://192.168.116.160:8080"
  updateYaml ${COA_CONFIG_DIR}/:1,$s/ concourse-micro-depls-username ${CONCOURSE_USER}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-micro-depls-password ${CONCOURSE_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-micro-depls-target ${CONCOURSE_ENDPOINT}

  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-master-depls-username ${CONCOURSE_USER}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-master-depls-password ${CONCOURSE_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-master-depls-target ${CONCOURSE_ENDPOINT}

  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-ops-depls-username ${CONCOURSE_USER}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-ops-depls-password ${CONCOURSE_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-ops-depls-target ${CONCOURSE_ENDPOINT}

  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-coab-depls-username ${CONCOURSE_USER}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-coab-depls-password ${CONCOURSE_PASSWORD}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-coab-depls-target ${CONCOURSE_ENDPOINT}

  MINIO_S3_KEY=$(getCredhubValue "/micro-bosh/minio-private-s3/s3_secretkey")
  updateYaml ${COA_CONFIG_DIR}/credentials-s3-br.yml s3-br-secret-key ${MINIO_S3_KEY}
  updateYaml ${COA_CONFIG_DIR}/credentials-s3-stemcell.yml s3-stemcell-secret-key ${MINIO_S3_KEY}

  commitGit "secrets" "set_coa_config"
}

#--- Configuration step after stemcells abd bosh releases download
Step_4() {
  display "INFO" "Set coa in offline mode"
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.boshreleases true
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.stemcells true
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml offline-mode.docker-images false
  updateYaml ${SECRETS_REPO_DIR}/private-config.yml precompile-mode: false
  commitGit "secrets" "set_coa_in_offline_mode"
}

#--- Configuration step after bosh-master deployment
Step_5() {
  display "INFO" "Update bosh password for concourse master pipelines"
  updateYaml ${COA_CONFIG_DIR}/credentials-master-depls-bosh-pipeline.yml bosh-password $(getCredhubValue "/micro-bosh/bosh-master/admin_password")
  commitGit "secrets" "update_bosh_master_password"

  display "INFO" "Enable \"intranet-interco-relay\" and \"openldap\" proxy operators for docker images download"
  disableOperator "${TEMPLATE_REPO_DIR}/master-depls/intranet-interco-relay/template/ssh-relay-registry-operators.yml"
  enableOperator "${TEMPLATE_REPO_DIR}/master-depls/intranet-interco-relay/template/ssh-relay-proxy-operators.yml"
  enableOperator "${TEMPLATE_REPO_DIR}/master-depls/openldap/template/3-proxy-operators.yml"
  commitGit "template" "set_proxy_conf_for_intranet_relay_and_openldap"
}

#--- Configuration step after bosh-ops deployment
Step_6() {
  display "INFO" "Update \"bosh-ops\" password for concourse ops pipelines"
  updateYaml ${COA_CONFIG_DIR}/credentials-ops-depls-bosh-pipeline.yml bosh-password $(getCredhubValue "/bosh-master/bosh-ops/admin_password")
  commitGit "secrets" "update_bosh_ops_password"

  display "INFO" "Enable \"jcr\" registry operators for docker images download cache"
  disableOperator "${TEMPLATE_REPO_DIR}/master-depls/intranet-interco-relay/template/ssh-relay-proxy-operators.yml"
  enableOperator "${TEMPLATE_REPO_DIR}/master-depls/intranet-interco-relay/template/ssh-relay-registry-operators.yml"
  disableOperator "${TEMPLATE_REPO_DIR}/master-depls/openldap/template/3-proxy-operators.yml"

  display "INFO" "Set \"jcr\" registry for concourse workers"
  OPS_DOMAIN=$(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain)
  updateYaml ${SHARED_SECRETS} secrets.coa.config.docker-registry-url "docker.jcr.${OPS_DOMAIN}/"
  commitGit "template" "enable_jcr_registry"

  #--- Log to credhub
  export CREDHUB_SERVER="https://credhub.internal.paas:8844"
  export CREDHUB_CLIENT="director_to_credhub"
  export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
  export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)
  credhub api > /dev/null 2>&1
  credhub login > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Credhub login failed"
  fi

  #--- Set concourse teams properties
  display "INFO" "Set \"jcr\" registry for concourse workers"
  TEAMS="main micro-depls master-depls ops-depls coab-depls cloudflare-depls remote-r2-depls remote-r3-depls utils"
  for team in ${TEAMS} ; do
    credhub d -n /concourse-micro/${team}/docker-registry-url > /dev/null 2>&1
    credhub s -t value -n /concourse-micro/${team}/docker-registry-url -v "docker.jcr.${OPS_DOMAIN}/" > /dev/null 2>&1
    if [ $? != 0 ] ; then
      display "ERROR" "Set propertie \"/concourse-micro/${team}/docker-registry-url\" to credhub failed"
    fi
  done
}

#--- Configuration step after gitlab deployment
Step_8.1() {
  display "INFO" "Initialize gitlab repositories"
  OPS_DOMAIN=$(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain)

  display "INFO" "Push coa \"master\" branch to gitlab repository"
  cd ${COA_REPO_DIR}
  flag=$(git remote -v | grep "^origin")
  if [ "${flag}" != "" ] ; then
    executeGit "remote remove origin"
  fi
  executeGit "remote add origin https://elpaaso-gitlab.${OPS_DOMAIN}/paas-template/coa.git"
  executeGit "pull inception master --rebase"
  executeGit "push -f -u origin master --tags"

  display "INFO" "Push secrets \"master\" branch to gitlab repository"
  cd ${SECRETS_REPO_DIR}
  flag=$(git remote -v | grep "^origin")
  if [ "${flag}" != "" ] ; then
    executeGit "remote remove origin"
  fi
  executeGit "remote add origin https://elpaaso-gitlab.${OPS_DOMAIN}/paas-template/secrets.git"
  executeGit "pull inception master --rebase"
  executeGit "push -f -u origin master --tags"

  display "INFO" "Push template branches to gitlab repository"
  cd ${TEMPLATE_REPO_DIR}
  flag=$(git remote -v | grep "^origin")
  if [ "${flag}" != "" ] ; then
    executeGit "remote remove origin"
  fi

  executeGit "remote add origin https://elpaaso-gitlab.${OPS_DOMAIN}/paas-template/paas-templates.git"

  display "INFO" "Push \"reference\" branch for concourse"
  executeGit "push -f origin reference --tags"

  display "INFO" "Push \"reference-wip-merged\" branch for concourse"
  executeGit "push -f origin reference:reference-wip-merged"

  display "INFO" "Push \"pipeline-current-reference-wip-merged\" branch for concourse"
  executeGit "push -f origin reference:pipeline-current-reference-wip-merged"

  currentBranch=$(git branch | grep "^* " | awk '{print $2}')
  display "INFO" "Push \"${currentBranch}\" branch to gitlab template repository"
  executeGit "pull inception ${currentBranch} --rebase"
  executeGit "push -f -u origin ${currentBranch}"
}

#--- Configuration step to set coa on gitlab repositories
Step_8.2() {
  printf "\n"
  catchValue "LDAP_CONCOURSE_PASSWORD" "Concourse ldap password"
  OPS_DOMAIN=$(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain)
  display "INFO" "Set \"concourse\" on gitlab repositories"
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml secrets-uri https://concourse:${LDAP_CONCOURSE_PASSWORD}@elpaaso-gitlab.${OPS_DOMAIN}/paas-template/secrets.git
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml paas-templates-uri https://concourse:${LDAP_CONCOURSE_PASSWORD}@elpaaso-gitlab.${OPS_DOMAIN}/paas-template/paas-templates.git
  updateYaml ${COA_CONFIG_DIR}/credentials-git-config.yml cf-ops-automation-uri https://concourse:${LDAP_CONCOURSE_PASSWORD}@elpaaso-gitlab.${OPS_DOMAIN}/paas-template/coa.git

  display "INFO" "Update concourse ops domain for pipelines"
  OPS_DOMAIN=$(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain)
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-micro-depls-target https://elpaaso-concourse.${OPS_DOMAIN}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-master-depls-target https://elpaaso-concourse.${OPS_DOMAIN}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-ops-depls-target https://elpaaso-concourse.${OPS_DOMAIN}
  updateYaml ${COA_CONFIG_DIR}/credentials-auto-init.yml concourse-coab-depls-target https://elpaaso-concourse.${OPS_DOMAIN}

  commitGit "secrets" "set_concourse_ops_domain"

  #--- Push updates to git-server on inception (git remote origin is connected to gitlab since previous step)
  cd ${SECRETS_REPO_DIR}
  executeGit "push -f inception"
}

#--- Execute configuration step
Step_$1

display "OK" "Configuration step \"$1\" ended"