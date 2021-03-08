#!/bin/bash

#This script restores on shield VM the latest valid archive (target shieldv8-ip, fs plugin)
#This script follows the steps :
#Get the latest valid archives from Shield
#Download from local S3 the archive
#Build a decrypt/uncompress script to be launched on the shield VM (internal vault constraint)
#Upload the archive to the shield VM (under /tmp)
#Upload the generated decrypt.sh script to the shield VM (under /tmp)
#Ask the operator to connect to the shield VM and to execute the generated script
#Pre-requisite : BOSH, SHIELD, CREDHUB and MC CLI installed
#Usage on docker-bosh-cli : restore-shield.sh
#Encryption key can be randomly generated or fixed
#Randomly generated based on shield archive UUID (shield archive commands returns FULL_UUID) // vault read secret/secret/archives/${FULL_UUID}
#Fixed vault read secret/secret/archives/fixed_key

#Get credhub data
/usr/local/bin/log-credhub.sh
S3_LOCAL_SECRET=$(credhub get --name /bosh-master/shieldv8/s3_secretkey | grep "value:" | cut -d " " -f 2)
echo "S3_LOCAL_SECRET : ${S3_LOCAL_SECRET}"
SHIELD_PASSWORD=$(credhub get --name /bosh-master/shieldv8/failsafe-password | grep "value:" | cut -d " " -f 2)
echo "SHIELD_PASSWORD (keep it) : ${SHIELD_PASSWORD}"
OPS_DOMAIN=$(credhub get --name /secrets/cloudfoundry_ops_domain | grep "value:" | cut -d " " -f 2)
echo "OPS_DOMAIN : ${OPS_DOMAIN}"
BUCKET_PREFIX=$(credhub get --name /secrets/backup_bucket_prefix | grep "value:" | cut -d " " -f 2)
echo "BUCKET_PREFIX : ${BUCKET_PREFIX}"

#Get logical dump to restore
export SHIELD_CORE=paas-templates
shield api -k https://shieldv8-webui.${OPS_DOMAIN} paas-templates
shield login -u admin -p ${SHIELD_PASSWORD}
shield archives --tenant micro-depls --target gitlab-data-192.168.116.211 --limit 1
ARCHIVE_UUID=$(shield archives --tenant micro-depls --target gitlab-data-192.168.116.211 --limit 1 | grep "bzip2" | grep -oE '[0-9a-f]{1,8}' | head -n 1)
ARCHIVE=$(shield archives --tenant micro-depls --target gitlab-data-192.168.116.211 --limit 1 | grep "bzip2" | grep -oE '[\/.][0-9]{1,4}[\/.][0-9]{1,2}[/\.][0-9]{1,2}[/\.][0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,6}-[0-9a-f]{1,8}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,12}' | head -n 1)
ARCHIVE_FILE=$(shield archives --tenant micro-depls --target gitlab-data-192.168.116.211 --limit 1 | grep "bzip2" | grep -oE '[0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,6}-[0-9a-f]{1,8}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,12}' | head -n 1)
echo "ARCHIVE_UUID : ${ARCHIVE_UUID}"
echo "ARCHIVE : ${ARCHIVE}"
echo "ARCHIVE_FILE : ${ARCHIVE_FILE}"
shield archive --tenant micro-depls ${ARCHIVE_UUID}
FULL_UUID=$(shield archive --tenant micro-depls ${ARCHIVE_UUID} | grep "UUID" | grep -oE '[0-9a-f]{1,8}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,12}' | head -n 1)
echo "FULL_UUID : ${FULL_UUID}"

#Get physical dump to restore from local s3
mc config host rm shield_local
mc config host add shield_local https://shield-s3.internal.paas shield-s3 ${S3_LOCAL_SECRET} -api S3v4
mc cp shield_local/${BUCKET_PREFIX}-gitlab${ARCHIVE} .

#Build decrypt script to be executed on shield VM
cat > decrypt.sh <<EOF
echo "SHIELD_PASSWORD to use : ${SHIELD_PASSWORD}"

#Get root token
/var/vcap/packages/shield/bin/shield op pry /var/vcap/store/shield/vault.crypt
export VAULT_CLIENT_CERT=/var/vcap/jobs/core/config/tls/vault.pub
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CLIENT_KEY=/var/vcap/jobs/core/config/tls/vault.key
export VAULT_SKIP_VERIFY=true

#Connect to vault and collect encryption information
echo "connect to vault and extract encryption information..."
/var/vcap/packages/vault/bin/vault auth
/var/vcap/packages/vault/bin/vault read secret/secret/archives/${FULL_UUID}

IV=\$(/var/vcap/packages/vault/bin/vault read secret/secret/archives/${FULL_UUID} | grep "iv" | grep -oE '[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}')
KEY=\$(/var/vcap/packages/vault/bin/vault read secret/secret/archives/${FULL_UUID} | grep "key" | grep -oE '[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}')
UUID=\$(/var/vcap/packages/vault/bin/vault read secret/secret/archives/${FULL_UUID} | grep "uuid" | grep -oE '[0-9a-f]{1,8}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,4}-[0-9a-f]{1,12}')
export enc_iv=\${IV}
export enc_key=\${KEY}
export enc_type="aes256-ctr"
echo "enc_iv : " \${enc_iv}
echo "enc_key : " \${enc_key}

#Decrypt archive file
echo "decrypt..."
rm -rf ${ARCHIVE_FILE}.out
/var/vcap/packages/shield/bin/shield-crypt --decrypt 3<<<"{\"enc_key\":\"\${enc_key}\",\"enc_iv\":\"\${enc_iv}\",\"enc_type\":\"\${enc_type}\"}" > ${ARCHIVE_FILE} <${ARCHIVE_FILE}.raw
file ${ARCHIVE_FILE}

#Uncompress using bunzip2
echo "decrypt..."
bunzip2 ${ARCHIVE_FILE}
rm -rf /tmp/work;mkdir /tmp/work
mv ${ARCHIVE_FILE}.out /tmp/work/.

#Uncompress using tar
cd /tmp/work
tar xvf ${ARCHIVE_FILE}.out
cd -
EOF

echo "Please log to bosh-master and to shieldv8 deployment"
. /usr/local/bin/log-bosh.sh
bosh -d shieldv8 ssh shield -c "sudo rm -rf /tmp/decrypt.sh"
bosh -d shieldv8 scp decrypt.sh shield:/tmp
bosh -d shieldv8 ssh shield -c "sudo rm -rf /tmp/${ARCHIVE_FILE}.raw"
bosh -d shieldv8 scp ${ARCHIVE_FILE} shield:/tmp/${ARCHIVE_FILE}.raw

echo "Please connect as root to the shield VM and execute under /tmp : bash decrypt.sh"
