# Admin tools

Paas-template `admin` directory contains scripts for operators in charge of tenant management.

## Cert management tools
  >**Note:**  
  > See `zz-docs/Certs_rotation.md` in paas-template repository.

  |Script name|Options|Description|
  |-----|-----|-----|
  |`check-expiry-certs.sh`|**--check-all, -a**: Check all certs (with coab instances)<br>**--expiry, -e**: Expiration delay (in days)|Check certs (in credhub and micro-bosh) that will expire within xx days|
  |`check-internal-ca-cert.sh`|**--expiry, -e**: Expiration delay (in days)|Check `internalCA` cert on each bosh instances of a specific bosh director.<br>Log on bosh director before using|
  |`check-pki-certs.sh`|none|Check PKI certs (api, ops, osb...) stored in `~/bosh/secrets/shared/certs` directories|
  |`delete-deployment-certs.sh`|none|Delete credhub certs for a specific bosh deployment (used for certs rotation)|
  |`delete-directors-certs.sh`|none|Delete credhub certs for a specific bosh director (used for certs rotation)|
  |`generate-certs-for-credub.sh`|none|Generate credhub and uaa certs, and jwt ssh public and private key|
  |`generate-internet-cert.sh`|none|Generate cert for internet access|
  |`generate-pki-csr.sh`|none|Generate private key and CSR for PKI certs (needed with PKI portal for certs generation)|
  |`renew-internal-ca.sh`|none|Renew `internalCA` cert (update expiration date, but keep the same private key|

## Other tools

  |Script name|Options|Description|
  |-----|-----|-----|
  |`functions.sh`|none|Common script library (source and used by admin scripts)|
  |`bosh-inventory.sh`|none|Get bosh vms properties for inventory and footprint (only active instances)|
  |`create-ldap-account.sh`|none|Create user account (admin, auditor) in paas-template ldap|
  |`delete-ldap-account.sh`|none|Delete user account (admin, auditor) in paas-template ldap|
  |`pause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)|Pause temporarly concourse pipelines and jobs (except "cloud-config-and-runtime-config")|
  |`unpause-jobs.sh`|**--exclude-jobs, -e**: Pause all jobs except job list (space separated)<br>**--pipeline, -p**: Target pipelines (space separated) for pausing jobs (default: all directors pipelines)<br>**--wait, -w**: Wait pause (seconds) before unpausing next jobs|Unpause selected concourse pipeline and associated jobs|
  |`recreate-micro-bosh.sh`|**--proxy, -p**: Set internet proxy (http://xxxx:xxxx)<br>**--recreate-certs, -r**: recreate micro-bosh certs<br>**--verbose, -v**: "debug" logs, otherwise "info" logs (default)|Recreate `micro-bosh` director|
