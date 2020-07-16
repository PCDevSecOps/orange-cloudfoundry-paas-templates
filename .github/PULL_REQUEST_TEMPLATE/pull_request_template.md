## feature-xxx

Short feature description.
New COA Profile xx added.

### New features for CloudFoundry and marketplace users

### New features for OSB client platforms

### New features for Operators

### Compliance
* Iaas Type
  * [ ] Openstack Iaas Type
  * [ ] vSphere Iaas Type
* Profiles
  * [ ] Apply on Profile xxx

### References
- https://github.com/orange-cloudfoundry/paas-templates/issues/xxx
- closes orange-cloudfoundry/paas-templates#xxx
- External releases notes https://...

#### Limitations (known remaining issues)
- https://github.com/orange-cloudfoundry/paas-templates/issues/xxx - short description

### Content (implementation)
* [ ] Add bosh deployment xxx
* [ ] Add a new terraform rule
* [ ] Add dns alias
* [ ] Fix security group xxx

### Manual platform ops

#### Pre-merge steps (before updating reference branch)
- Do xx
- Do yy

#### Pre-upgrade steps (once reference branch is merged, upgrade prerequisite. Config/secrets update)
- Do xx
- Do yy

#### Post-upgrade steps (after upgrade pipeline is done)
- Do xx
- Do yy

#### Clean-up steps (final clean, when platform state is ok. Can be applied out of upgrade maintenance window)
- Do xx
- Do yy

### Expected upgrade availability impacts during maintenance window

#### CloudFoundry and marketplace users
- cf api: down xxx mn
- cf apps exposition: down xxx mn
- Marketplace service usage: down xxx mn
- Marketplace service management (eg: dashboards): down xxx mn

#### OSB client platforms
- Marketplace service provisionning: down xxx mn

#### Operators
- Monitoring on xxx lost: down xxxx mn
- Concourse portal down: down xxx mn
- Transient concourse job xxx failure
