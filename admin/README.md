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
  |`recreate-micro-bosh.sh`|**--proxy, -p**: Set internet proxy (http://xxxx:xxxx)<br>**--recreate-certs, -r**: recreate micro-bosh certs<br>**--verbose, -v**: "debug" logs, otherwise "info" logs (default)|Recreate micro-bosh and delete micro-bosh director certs|
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
  |`create-ldap-account.sh`|none|Create user account (admin, auditor) in paas-template ldap|
  |`delete-ldap-account.sh`|none|Delete user account (admin, auditor) in paas-template ldap|
  |`disable-branch.sh`|none|Disable feature branches|
  |`enable-branch.sh`|none|Enable disabled feature branches|
  |`get-bosh-manifests.sh`|none|Get cloud/runtime config and manifests from all deployments|
  |`pause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)|Pause temporarly concourse pipelines and jobs (except "cloud-config-and-runtime-config")|
  |`reboot-concourse-workers.sh`|none|Restart unstable concourse workers|
  |`recreate-bosh-deployments.sh`|none|Recreate all deployments managed by a selected bosh director|
  |`retrigger-failed-jobs.sh`|none|Retrigger all concourse failed jobs|
  |`send-mail.sh`|none|Send mail from environment|
  |`set-env.sh`|none|Set environment for `jumpbox` and `inception` instances|
  |`unpause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)<br>**--wait, -w**: Wait pause (seconds) before unpausing next jobs|Unpause selected concourse pipeline and associated jobs|
