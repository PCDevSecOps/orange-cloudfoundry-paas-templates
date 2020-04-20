**Step 0 : Disable old deployment deployment**
- remove coab-depls/casssandravarops/enable-deployment.yml file in secrets repository
- commit and push to Git

**Step 1 : Load cassandra v10 bosh release**
- trigger coab-depls-bosh-generated/execute-deploy-script job

**Step 2 : Setup new skeleton deployment**
- create the following tree (directories and files) by using the given resources (1_coab-skeleton-deployment)
```
├── coab-depls
│   ├── cassandra
│   │   ├── enable-deployment.yml
│   │   └── secrets
│   │       ├── meta.yml
│   │       └── secrets.yml
```
- commit and push to Git the whole files

**Step 3 : Checks**
- on Concourse GUI (connected as main team), on coab-depls-bosh-generated pipeline (Terraform part), trigger the job check-terraform-consistency
    - Check that the only resource to create is cloudfoundry_service_broker.tf-coab-cassandra
    - If it is the case, trigger the job approve-and-enforce-terraform-consistency 
on Concourse GUI, check the smoke test status (should be green) for cf-push-coa-cassandra-broker (pipeline coab-depls-cf-apps-generated)

