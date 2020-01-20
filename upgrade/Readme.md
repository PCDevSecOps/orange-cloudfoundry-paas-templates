# Upgrade Framework

## Directory overview

```
.
├── lib                         => Ruby library
│   ├── paas_templates_upgrader
│   └── upgrade                 => Ruby library usable by upgrade scripts
├── pipelines                   => static pipeline for upgrade initialization
├── pipeline-templates          => dynamic pipeline templates 
├── releases                    => scripts used to upgrade to required version
│   └── v44.0.0
│       ├── 05-pre-merge        => pre-merge step    
│       │   └── openstack-hws
│       │   └── vsphere
│       ├── 10-pre-upgrade      => pre-upgrade step
│       │   └── openstack-hws
│       │   └── vsphere
│       ├── 20-post-upgrade     => post-merge step
│       │   └── openstack-hws
│       │   └── vsphere
│       └── 30-cleanup          => cleanup step
│       │   └── openstack-hws
│       │   └── vsphere
└── scripts                     => internal scripts
```


## Lifecycle Overview

  1. `pre-merge` step: no operations performed, the new paas-templates version is not published on local gitlab (ie feature branches are not available), automatic trigger        
  
  2. `pre-upgrade` step: rebase of feature branches (Coab and Custom), feature branches are available, automatic trigger
  
  3. `post-upgrade` step: all deploy, automatic trigger (such as extra broker configuration)
  
  4. `cleanup` step: should perform cleanup operation, once everything has been successfully executed, manually trigger
  
## Conventions
 * cloud foundry scripts, must match `CF-*` regexp
 * standard scripts, must start match `[0-9][0-9]-*` regexp
 * IAAS_TYPE is supported, create a subdirectory, named like your iaas type, into required step
 * each upgrade script is invoked with a single parameter: path to config repository. For instance, for bash script, you should have `CONFIG_DIR="$1"` as one of your first script line.
 * Cloud Foundry scripts are already logged on CF
 * Common script are logged in Credhub

## Local execution

Options are identical between standard and cf scripts  
* Use `-f` to run an upgrade script subset
* Use `--iaas` to run an upgrade script subset
* Use `--step` to select a step with script
* Use `-c` to use a config repository to upgrade

use `-h` to display full help
 
### Run upgrade
#### Sample
```bash
cd upgrade
./run_upgrade.rb -v 44.0.0 -c ../../dev-secrets -s preupgrade
```

#### Vsphere cleanup sample
```bash
cd upgrade
./run_upgrade.rb -v 44.0.0 -c ../../int-secrets --iaas vsphere -s cleanup -f "01-feature*"
```


#### Openstack cleanup sample
```bash
cd upgrade
 ./run_upgrade.rb -v 44.0.0 -c ../../int-secrets --iaas openstack-hws -s cleanup -f "01-cloudflare-secret-cleanup" 
```

### Run CF upgrade

#### Sample
```
./run_cf_upgrade_command.rb -v 44.0.0 -c ../../int-secrets -s premerge
```