# Admin tools

Paas-template `admin` directory contains scripts for operators in charge of tenant management.

## Cert management tools

  >**Note:** See `admin/certs_rotation.md` guideline in paas-template repository.

  |Script name|Options|Description|
  |-----------|-------|-----------|
  |`bosh-redeploy.sh`|**step number**|Redeploy linked bosh deployments for "3 steps rotation" process|
  |`check-certs.sh`|**--coab-excluded, -c**: Check certs without coab instances<br>**--expiry, -e**: Expiration delay (in days)|Check certs (in credhub and micro-bosh) that will expire within xx days|
  |`check-internal-ca-cert.sh`|**--expiry, -e**: Expiration delay (in days)|Check `internalCA` cert on each bosh instances of a specific bosh director|
  |`create-pki-csr.sh`|none|Create private key and CSR for PKI certs generation (needed with PKI portal)|
  |`delete-deployment-certs.sh`|none|Delete credhub certs for a specific bosh deployment (except micro-bosh)|
  |`get-certs-by-ca.sh`|none|Get all CA certs in credhub and display their leaf certs|
  |`get-mtls-certs.sh`|none|Get deployments which use MTLS certs (not those used locally inside deployment)|
  |`recover-bosh-agent.sh`|none|Recover `unresponsive agent` instances status for a bosh director|
  |`recreate-bosh-deployments.sh`|none|Recreate all active bosh deployments from a selected bosh director|
  |`renew-certs-3-steps.sh`|none|renew credhub certs for "3 steps rotation" process (CA recreation, leaf certs recreation, old ca and certs deletion)|
  |`renew-certs-for-bosh-dns.sh`|none|Renew bosh-dns certs|
  |`renew-certs-for-credhub.sh`|none|Renew credhub and uaa certs, and jwt ssh public and private key for credhub deployment|
  |`renew-internal-ca.sh`|none|Renew `internalCA` cert (update expiration date with the same private key|
  |`show-credhub-certs.sh`|none|Show credhub certs properties|

## Other admin tools

  |Script name|Options|Description|
  |-----------|-------|-----------|
  |`activate-openstack-vpn.sh`|none|Activate prerequisite (disable src ip check and delete terraform static routes) when recreate openstack vpn instances (use `log-openstack` before)|
  |`check-deployments-version.sh`|**-h**: Help for options|Check paas-templates-version tag in all bosh manifests from secrets repository|
  |`check-old-stemcells.sh`|none|Check bosh deployments using obsolete stemcells for all bosh directors|
  |`check-vpn-probes.sh`|none|Check R2/R3 vpn probes bandwidth|
  |`check-vsphere-vms.sh`|none|Check incoherent vms (duplicate ips, orphaned) on vsphere vcenter|
  |`clean-credhub-properties.sh`|none|Delete credhub obsolete properties and certs versions|
  |`clean-minio-buckets.sh`|none|Delete minio obsolete stemcells, cached buildpacks and bosh releases|
  |`clean-openstack-stemcells.sh`|none|Delete obsolete stemcells in openstack IAAS (use `log-openstack` before)|
  |`create-ldap-account.sh`|none|Create user account (admin, auditor) in paas-template ldap|
  |`delete-k8s-ns.sh`|none|Delete k8s namespace (when stuck) (use `log-k8s` before)|
  |`delete-ldap-account.sh`|none|Delete user account (admin, auditor) in paas-template ldap|
  |`disable-branch.sh`|none|Disable feature branches|
  |`enable-branch.sh`|none|Enable disabled feature branches|
  |`get-bosh-inventory.sh`|none|Get bosh vms properties (only active instances) for inventory and footprint|
  |`get-bosh-manifests.sh`|none|Get cloud/runtime config and manifests from all deployments|
  |`get-vm-info.sh`|none|Get vsphere vm informations from it's ip (use `log-govc` before)|
  |`init-git.sh`|none|Init minimal git config|
  |`init-mc.sh`|none|Init mc cli config for minio access|
  |`pause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)|Pause temporally concourse pipelines and jobs (except "cloud-config-and-runtime-config")|
  |`pause-pipelines.sh`|**--exclude-pipelines, -e**: Pause all pipelines except pipeline list (space separated)|Pause temporally concourse pipelines|
  |`rebase-paas-templates-branches.sh`|**-h**: Help for options|Rebase feature branches for upgrade|
  |`reboot-vsphere-vms`|none|reboot vsphere vms on selected region (hen guest file systems become read only)|
  |`recreate-bosh-deployments.sh`|none|Recreate all deployments managed by a selected bosh director|
  |`recreate-micro-bosh.sh`|**--proxy, -p**: Set internet proxy (http://xxxx:xxxx)<br>**--recreate-certs, -r**: recreate micro-bosh certs<br>**--verbose, -v**: "debug" logs, otherwise "info" logs (default)|Recreate micro-bosh instance and delete micro-bosh director certs|
  |`reinit-ldap-pwd.sh`|none|Reinitalize all user passwords (except concourse) in paas-template ldap|
  |`retrigger-failed-jobs.sh`|none|Retrigger concourse failed jobs|
  |`send-mail.sh`|none|Send mail from environment|
  |`set-env.sh`|none|Set environment for `jumpbox` instances|
  |`unpause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)<br>**--wait, -w**: Wait pause (seconds) before unpausing next jobs|Unpause selected concourse pipeline and associated jobs|
  |`unpause-pipelines.sh`|**--exclude-pipelines, -e**: Pause all pipelines except pipeline list (space separated)|Unpause concourse pipelines|
