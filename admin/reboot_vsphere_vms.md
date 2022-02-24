# Reboot vsphere instances

This document is a guideline to fix read only guest file systems on vsphere vms, after storage network unavailability.  

This operation needs 2 steps:
1. Reboot `control plane` vms from vsphere iaas, only when storage network unavailability is resolved
2. Fix `data plane`, when bosh director resurrector could not fix `unresponsive agent` status on backend services deployments

## Prerequisites

- From your **local** laptop, you have to check if **gitlab access is available**, and then get last updates from `template` and `secrets` repositories (admin scripts are based on)

  `pull method` (local repositories exists and set to target gitlab remote repository)

  ```
  cd ~/bosh/secrets ; git remote -v
  git pull --rebase

  cd ~/bosh/template ; git remote -v
  git checkout reference ; git pull --rebase
  ```

  `clone method`

  ```
  rm -fr ~/bosh/template ~/bosh/secrets
  git clone <paas_template_url> ~/bosh/template
  git clone <secrets_url> ~/bosh/secrets
  ```

>**Note:**  
> If **gitlab access is not available**, you can set following files from an existing repositories clone
> - `~/bosh/template/admin/reboot-vsphere-vms.sh` script (could be catch from reference repository)
> - `~/bosh/secrets/shared/secrets.yml` credential file
> - `~/bosh/secrets/shared/keypair/inception.pem` inception key file

## Reboot control plane instances

- Connect to `cactus vpn` with your access id and reboot vsphere instances for main bosh directors (`micro`, `master` and `remote-r2`)

  ```
  ~/bosh/template/admin/reboot-vsphere-vms.sh
  ```

- Connect to `inception` instance

  ```
  INCEPTION_INTRANET_IP=<inception intranet_interco ip>
  INCEPTION_KEY=~/bosh/secrets/shared/keypair/inception.pem

  chmod 600 ${INCEPTION_KEY} ; ssh inception@${INCEPTION_INTRANET_IP} -i ${INCEPTION_KEY}
  ```

- Check all bosh deployments from `micro-bosh` director and current resurrector tasks, then fix potential problems

  ```
  log-bosh (select "micro-bosh" and no specific deployment)
  bosh tasks
  bosh is
  ```

- Check all bosh deployments from other bosh director (master, remote-r2) and current resurrector tasks, then fix potential problems

  ```
  log-bosh (select director and no specific deployment)
  bosh tasks
  bosh is
  ```

## Fix data plane ops and coab deployments (backend-services)

>**Note:**  
> Backend services deployment instances need to be reboot consistently, especially when use clusters.
> So, to be sure that deployments will be restarted with consistency, you need to use bosh for next operations.

- Connect to `docker-bosh-cli` instance (if usable) with your ldap account, otherwise continue to use `inception` instance

- log to `bosh-ops` director, then check all bosh deployments and current resurrector tasks

  ```
  log-bosh (select director and no specific deployment)
  bosh tasks
  bosh is
  ```

- If deployment has `unresponsive agent` vms status, select deployment with `switch` or `-d <deployment>` option for bosh cli, then reconciliate (select reboot option) bosh deployment with iaas

  ```
  bosh cck
  ```

## Fix Galera clusters

- Select deployment with `switch` tool (avoid to specify `-d <deployment>` option for bosh cli)

### Use case 1: Cluster lost all its members

```
Instance                                            Process State  AZ  IPs              VM CID                                VM Type
mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3          failing        z1  192.168.250.164  39ffc7ea-e3d3-4c4f-a0a4-6973cd819bb0  default
mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6          failing        z1  192.168.250.179  19a4bd1c-f1af-4ed0-93cd-480ffe7e0a87  default
mysql/fa70a718-d611-4f6e-a148-e26c05cdb910          failing        z1  192.168.250.152  6a12edd7-a553-4368-b60f-854f4b1fa361  default
```

- Galera clusters should need to synchronise transactions between mysql nodes with `bootstrap` errand

  ```
  bosh run-errand bootstrap -keep-alive
  ```

- If errand fails with error, then you have to manually fix the cluster

- Access to a `failing` node, stop mariaDB controler and check mysql sequence number

  ```
  bosh ssh mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6
  sudo -i
  monit stop mariadb_ctrl
  monit summary

  cat /var/vcap/store/mysql/grastate.dat | grep "seqno:"
  ```

- If `seqno` value is `-1` then restart mysql instance in `Recover mode`

  ```
  /var/vcap/packages/mariadb/bin/mysqld --wsrep-recover
  ```

- If `seqno` value stay to `-1` then you need to search sequence value in `mysql.err.log` file

  ```
  grep "Recovered position" /var/vcap/sys/log/mysql/mysql.err.log | tail -1

  170907 16:10:18 mysqld_safe WSREP: Recovered position cc7d53a0-93c9-11e7-8505-42de3c71a9a9:30
  ```

  - In the previous exemple, `seqno` value (at the end of the line) is `30`

- You must repeat previous steps with all `mysql` nodes to identify node with the highest `seqno`

- Restart the 1st node of the cluster (node with the highest `seqno`)

  ```
  bosh ssh mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3
  sudo -i
  echo -n "NEEDS_BOOTSTRAP" > /var/vcap/store/mysql/state.txt
  chown vcap:vcap /var/vcap/store/mysql/state.txt
  monit start mariadb_ctrl
  monit summary
  ```

- Then check cluster status from bosh deployment

  ```
  bosh is

  Instance                                            Process State  AZ  IPs              VM CID                                VM Type
  mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6          failing        z1  192.168.250.179  19a4bd1c-f1af-4ed0-93cd-480ffe7e0a87  default
  mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3          running        z1  192.168.250.164  39ffc7ea-e3d3-4c4f-a0a4-6973cd819bb0  default
  mysql/fa70a718-d611-4f6e-a148-e26c05cdb910          failing        z1  192.168.250.152  6a12edd7-a553-4368-b60f-854f4b1fa361  default
  ```

### Use case 2: Cluster exists but lost 2 members

```
Instance                                            Process State  AZ  IPs              VM CID                                VM Type
mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3          running        z1  192.168.250.164  39ffc7ea-e3d3-4c4f-a0a4-6973cd819bb0  default
mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6          failing        z1  192.168.250.179  19a4bd1c-f1af-4ed0-93cd-480ffe7e0a87  default
mysql/fa70a718-d611-4f6e-a148-e26c05cdb910          failing        z1  192.168.250.152  6a12edd7-a553-4368-b60f-854f4b1fa361  default
```

- Check galera cluster status on `running` instance

  ```
  bosh ssh mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3
  sudo -i
  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_status";'

  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | wsrep_cluster_status | Primary |
  +----------------------+---------+
  ```

- If `wsrep_cluster_status` propertie is `Primary`, the cluster is ready

- If `wsrep_cluster_status` propertie is `non-Primary`, you need to perform an automatic bootstrap

  ```
  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf
  mysql> SET GLOBAL wsrep_provider_options='pc.bootstrap=YES';
  mysql> SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status';

  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | wsrep_cluster_status | Primary |
  +----------------------+---------+
  ```

- Access to a `failing` node and stop mariaDB controler

  ```
  bosh ssh mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6
  sudo -i
  monit stop mariadb_ctrl
  monit summary
  ```

- Remove `mysql` instance persistent data, then recreate instance

  ```
  rm -rf /var/vcap/store/mysql
  /var/vcap/jobs/mysql/bin/pre-start
  ```

- Restart mariaDB controler, and check cluster status and cluster size

  ```
  monit start mariadb_ctrl
  monit summary
  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_status";'

  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | wsrep_cluster_status | Primary |
  +----------------------+---------+

  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_size";'

  +--------------------+-------+
  | Variable_name      | Value |
  +--------------------+-------+
  | wsrep_cluster_size | 2     |
  +--------------------+-------+
  ```

### Use case 3: Cluster exists but lost 1 member

```
Instance                                            Process State  AZ  IPs              VM CID                                VM Type
mysql/8fdd66fa-cc34-4a22-9c7d-75835dc438f6          running        z1  192.168.250.179  19a4bd1c-f1af-4ed0-93cd-480ffe7e0a87  default
mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3          running        z1  192.168.250.164  39ffc7ea-e3d3-4c4f-a0a4-6973cd819bb0  default
mysql/fa70a718-d611-4f6e-a148-e26c05cdb910          failing        z1  192.168.250.152  6a12edd7-a553-4368-b60f-854f4b1fa361  default
```

- Check galera cluster status on `running` instance

  ```
  bosh ssh mysql/f14876bd-df5a-4eaf-86a2-711d91ea61d3
  sudo -i
  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_status";'

  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | wsrep_cluster_status | Primary |
  +----------------------+---------+
  ```

- Force `failing` node to rejoin cluster with `rejoin-unsafe` errand

  ```
  bosh run-errand rejoin-unsafe
  ```

- Check cluster status and cluster size

  ```
  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_status";'

  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | wsrep_cluster_status | Primary |
  +----------------------+---------+

  mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf -e 'SHOW STATUS LIKE "wsrep_cluster_size";'

  +--------------------+-------+
  | Variable_name      | Value |
  +--------------------+-------+
  | wsrep_cluster_size | 3     |
  +--------------------+-------+
  ```