# problem
Each dedicated services own its proper backup configuration (shield server and agents)
Shield stores its backup/restore inventory in a sqlite database
The database is stored on an ephemeral disk instead of a persistent disk
Consequently, each time the shield VM is recreated (bosh recreate, stemcell upgrade, ...), the backup/restore inventory is lost

# solution

## head lines
- backup inventories for all dedicated instances(cp from /var/vcap/store/shield to /tmp/shield)
- apply changes on deployments 
- restore inventories for all dedicated instances(cp from /tmp/shield to /var/vcap/store/shield)
## pause job
```bash
cd ~/bosh/template/admin
pause-jobs.sh -p coab
```

## backup inventory (bash script included in branch feature-fix-shield-storage-on-coab-depls)
- on bosh-cli, connect to bosh-coab director 
```bash
log-bosh
```
- use coab-depls/ops-scripts/repair_shield.sh
```bash
repair_shield.sh -b
```

PS : ignore errors on redis (no backup solution)

## adapt the deployment configuration (included in branch feature-fix-shield-storage-on-coab-depls)
- change manifest for cf-mysql, cf-rabbit, mongodb and cassandra model deployments
- change deployment-dependencies files in order to allow COAB retrofit 

## unpause job
```bash
cd ~/bosh/template/admin
unpause-jobs.sh -p coab
```


## restore inventory (bash scripts included in branch feature-fix-shield-storage-on-coab-depls)
- on bosh-cli, connect to bosh-coab director 
```bash
log-bosh
```
- pause job
```bash
cd ~/bosh/template/admin
pause-jobs.sh -p coab
```
- use coab-depls/ops-scripts/repair_shield.sh
```bash
repair_shield.sh -r
```
- use coab-depls/ops-scripts/unlock_shield.sh
```bash for PROD
unlock_shield.sh <OPS_DOMAIN_PROD>
```
```bash for PPROD
unlock_shield.sh <OPS_DOMAIN_PPROD>
```
```bash for INT
unlock_shield.sh <OPS_DOMAIN_INT>
```
PS : ignore errors on redis (no backup solution)
- unpause job
```bash
cd ~/bosh/template/admin
unpause-jobs.sh -p coab
```
