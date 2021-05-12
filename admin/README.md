# Admin tools

Paas-template `admin` directory contains scripts for operators in charge of tenant management.

## Cert management tools
  >**Note:**  
  > See `admin/certs_rotation.md` guideline in paas-template repository.

  |Script name|Options|Description|
  |-----|-----|-----|
  |`bosh-redeploy.sh`|**step number**|Redeploy linked bosh deployments for 3 steps rotation process|
  |`check-certs.sh`|**--coab-excluded, -c**: Check certs without coab instances<br>**--expiry, -e**: Expiration delay (in days)|Check certs (in credhub and micro-bosh) that will expire within xx days|
  |`check-internal-ca-cert.sh`|**--expiry, -e**: Expiration delay (in days)|Check `internalCA` cert on each bosh instances of a specific bosh director|
  |`delete-deployment-certs.sh`|none|Delete credhub certs for a specific bosh deployment (except micro-bosh)|
  |`generate-internet-cert.sh`|none|Generate cert for internet access|
  |`generate-pki-csr.sh`|none|Generate private key and CSR for PKI certs generation (needed with PKI portal)|
  |`get-certs-by-ca.sh`|none|Get all CA certs in credhub and display their leaf certs|
  |`recover-bosh-agent.sh`|none|Recover `unresponsive agent` instances status for a bosh director|
  |`recreate-bosh-deployments.sh`|none|Recreate all active bosh deployments from a selected bosh director|
  |`regenerate-certs-for-bosh-dns.sh`|none|Generate bosh-dns certs|
  |`regenerate-certs-for-credhub.sh`|none|Generate credhub and uaa certs, and jwt ssh public and private key for credhub deployment|
  |`renew-certs.sh`|none|Regenerate credhub certs in 3 steps (CA recreation, leaf certs recreation, old ca and certs deletion)|
  |`renew-internal-ca.sh`|none|Renew `internalCA` cert (update expiration date with the same private key|
  |`show-credhub-certs.sh`|none|Show credhub certs properties|

## Other tools

  |Script name|Options|Description|
  |-----|-----|-----|
  |`bosh-inventory.sh`|none|Get bosh vms properties (only active instances) for inventory and footprint|
  |`clean-credhub-properties.sh`|none|Delete credhub obsolete properties and certs versions|
  |`clean-minio-buckets.sh`|none|Delete minio obsolete stemcells, cached buildpacks and bosh releases|
  |`clean-openstack-stemcells.sh`|none|Delete obsolete stemcells in openstack IAAS (use `log-openstack` before)|
  |`create-ldap-account.sh`|none|Create user account (admin, auditor) in paas-template ldap|
  |`delete-ldap-account.sh`|none|Delete user account (admin, auditor) in paas-template ldap|
  |`disable-branch.sh`|none|Disable feature branches|
  |`enable-branch.sh`|none|Enable disabled feature branches|
  |`get-bosh-manifests.sh`|none|Get cloud/runtime config and manifests from all deployments|
  |`get-old-stemcells.sh`|none|Get bosh deployments using obsolete stemcells for all bosh directors|
  |`init-git.sh`|none|Init minimal git config|
  |`init-mc.sh`|none|Init mc cli config for minio access|
  |`pause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)|Pause temporarly concourse pipelines and jobs (except "cloud-config-and-runtime-config")|
  |`pause-pipelines.sh`|**--exclude-pipelines, -e**: Pause all pipelines except pipeline list (space separated)|Pause temporarly concourse pipelines|
  |`rebase-paas-templates-branches.sh`|**-h**: Help for options|Rebase feature branches for upgrade|
  |`reboot-concourse-workers.sh`|none|Restart unstable concourse workers|
  |`recreate-bosh-deployments.sh`|none|Recreate all deployments managed by a selected bosh director|
  |`recreate-inception.sh`|**--proxy, -p**: Set internet proxy (http://xxxx:xxxx)<br>**--verbose, -v**: "debug" logs, otherwise "info" logs (default)|Recreate inception instance. See `admin/inception_recreation.md` guideline|
  |`recreate-micro-bosh.sh`|**--proxy, -p**: Set internet proxy (http://xxxx:xxxx)<br>**--recreate-certs, -r**: recreate micro-bosh certs<br>**--verbose, -v**: "debug" logs, otherwise "info" logs (default)|Recreate micro-bosh instance and delete micro-bosh director certs|
  |`reinit-ldap-pwd.sh`|none|Reinitalize all user passwords (except concourse) in paas-template ldap|
  |`retrigger-failed-jobs.sh`|none|Retrigger all concourse failed jobs|
  |`send-mail.sh`|none|Send mail from environment|
  |`set-env.sh`|none|Set environment for `jumpbox` and `inception` instances|
  |`unpause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)<br>**--wait, -w**: Wait pause (seconds) before unpausing next jobs|Unpause selected concourse pipeline and associated jobs|
  |`unpause-pipelines.sh`|**--exclude-pipelines, -e**: Pause all pipelines except pipeline list (space separated)|Unpause concourse pipelines|
