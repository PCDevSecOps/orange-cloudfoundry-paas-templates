# Paas-template upgrade process

## Conventions

- If Concourse jobs begins with `OPS-manually*`, its requires manual external tasks/checks (jobs are just reminder for steps but no automated tasks are applied)
- If Concourse jobs begins with `manual-step*`, you need to trigger then manually to achieve following automated tasks

>**Note:**  
> Be careful, some `manual-step-xx` jobs are not correctly displayed in concourse webui. So you can clearly identify jobs order whith their names `step-x-xxxx` 

## Load upgrade pipelines from pre-install branch
[//]: # (TODO pre-merge - Load upgrade pipelines from pre-install branch)

>**Note:**  
> For next operations, ensure you pushed your previous updates (if exists) in each repository before deleting directories

1. Set pre-requisites on `operator local env` (your laptop)

- `~/bosh/secrets` => Up to date `secrets` clone from `target repository` you want to upgrade

  ```
  cd ~/bosh
  rm -fr secrets
  git clone <target_secrets_repo_url> secrets
  ```

- `~/bosh/template` => Up to date `paas-template` clone from `reference repository` (`Orange forge` or `FE-INT`) containing **tagged version** to install

  ```
  cd ~/bosh
  rm -fr template
  git clone <reference_repo_url> template
  cd template
  ```

- Check that <tag_version> exists and is associated with HEAD commit

  ```
  git fetch --tags
  git log

  #--- If HEAD is not pointing at same commit than current branch, you may reset to the tag
  #--- Warning: this would remove more recent commits from current branch
  git reset --hard <tag_version>
  git log
  ```

2. Push `reference` branch to a new branch called `pre-install-v<tag_version>` on your `gitlab` target environment (tag version is defined using `meta-inf.yml`. Check script option to override if needed)

    ```
    ~/bosh/template/upgrade/publish-paas-template-into-local-gitlab-pipeline.sh
    ```

3. Switch to `docker-bosh-cli` and set pre-requisites

>**Note:**  
> For next operations, ensure you pushed your previous updates (if exists) in each repository before deleting directories

- `~/bosh/template` => Up to date `paas-template` clone from target gitlab repository you want to upgrade, on branch `pre-install-v<tag_version>`

  ```
  cd ~/bosh
  rm -fr template
  git clone <target_template_repo_url> template
  cd template
  git checkout pre-install-v<tag_version>
  ```

- `~/bosh/secrets` => Up to date `secrets` clone from target gitlab repository you want to upgrade

  ```
  cd ~/bosh
  rm -fr secrets
  git clone <target_secrets_repo_url> secrets
  ```

4. Update `paas-template` and `coa` versions credhub properties and load upgrade pipeline

    ```
    cd ~/bosh/template/upgrade
    update-upgrade-param.sh
    load-upgrade-pipeline.sh
    ```

5. Ensure concourse jobs from `main/init-upgrade-pipelines` pipeline turn green before operating next step  
`display-meta-inf` job may need to be retriggered manually to turn green, if the update pipeline from previous version was not cleaned up  
Check that branch name is valid in the inputs of `reload-this-pipeline-from-git` and matches the pre-install branch name (version to install)

## Bump Cf-Ops-Automation
[//]: # (TODO pre-merge - Bump Cf-Ops-Automation)

1. Protect unmanaged bosh deployments from COA automatic cleanup 

    >**/!\ Caution**  
    > Since version 4.2.0, COA implements a new delete mechanism that synchronizes bosh deployments and secrets repository declaration  
    > Every bosh deployments must be declared in secrets repository, otherwise bosh deployments will be deleted  
    > To avoid deletion, a bosh deployment that was not managed by paas-templates must be `protected` by creating an empty file called `protect-deployment.yml` as below

    ```
    #--- Step 1: identify unmanaged bosh deployments for each bosh director
    log-bosh
    bosh deployments
    
    #--- For each unmanaged bosh deployment, protect it if the deployment has to be be preserved
    cd ~/bosh/secrets/
    touch ops-depls/my-prototype-bosh-deployment/protect-deployment.yml
    git add ops-depls/my-prototype-bosh-deployment/protect-deployment.yml
    git commit -m "protect unmanaged bosh deployment" ; git push
    ```

2. Bump `cf-ops-automation` to `4.3.2` version on `gitlab` to your target environment (if needed)

    >**Note:**  
    > This operation is useful when COA is mirrored on `local gitlab`, or when your COA version does not match expected version. If fetched from github (see secret config below), this step can be skipped

    ```
    $ grep cf-ops-automation-uri ~/bosh/secrets/coa/config/credentials-git-config.yml 
    cf-ops-automation-uri: https://github.com/orange-cloudfoundry/cf-ops-automation.git
    ```

    ```
    cd ~/bosh
    rm -fr coa
    proxy
    git clone -b master https://github.com/orange-cloudfoundry/cf-ops-automation.git ~/bosh/coa
    proxy
    cd ~/bosh/coa
    git reset --hard v4.3.2
    gitlog
    git remote add gitlab '<coa_gitlab_repo_url>'
    git push -f --tags gitlab master
    ```

3. Ensure concourse jobs (in `main` team) from `init-upgrade-pipelines` pipeline turn green before operating next step (`display-meta-inf` may need to be retriggered manually to turn green, if the update pipeline from previous version was not cleaned up)

4. Trigger `coa-v*-upgrade/WARNING-This-pipeline-updates-secrets-repository` concourse job, and ensure steps turn green before operating next step

    If some concourse jobs turn orange (erroring due to race condition between builds triggered shared/secrets, and COA updated pipelines), then trigger manually failed jobs

    > Errors that can be observed in `master-depls-bosh-generated/jobs/cloud-config-and-runtime-config-for-master-depls`  
    > task config 'cf-ops-automation/concourse/tasks/bosh_update_cloud_config.yml' not found

## Bump paas-template
[//]: # (TODO - MERGE paas-templates bump)

  >**Note:**  
  > During this step, some jobs are paused in the different pipelines to allow upgrade process  
  > Pausing pipelines induces on demand service provisioning unavailability (eg: new COAB services can't be created while concourse is paused. They will fail with a user-facing timeout)

### Synchronize paas-template to local gitlab (OPS-manually-synchronize-paas-template-to-local-gitlab)
[//]: # (TODO - pre-merge manual ops steps and push release)

1. Trigger `paas-templates-*-upgrade/WARNING-This-pipeline-updates-secrets-repository` concourse job, and ensure automated steps turn green before operating next step

2. Unprotect `reference` branch on `gitlab` before triggering following job. Connect to gitlab and use the menu `Settings->Repository->Protected Branches`

3. Push new paas-templates release to gitlab with `upgrade-to-paas-templates-*/promote-pre-install-to-reference` job before triggering `OPS-manually-synchonize-paas-template-to-local-gitlab` job

>**Caution:**  
> `promote-pre-install-to-reference` job sets `reference` branch with target content  
> It needs to be triggered `before` manually triggering the `OPS-manually-synchonize-paas-template-to-local-gitlab` job

4. Protect back the `reference` branch in gitlab (`no-one` allow to push and merge)

5. Check that `paas-templates-xx-upgrade/reset-paas-templates-WIP-to-reference` turns green (this job prepares the next steps **rebase XX branches**)

6. Check Release Note to apply features related credentials/operations steps in `Pre-merge steps` sections, then commit and push updates to repository (if needed)

7. Trigger `paas-templates-xx-upgrade/OPS-manually-synchronize-paas-template-to-local-gitlab`

### Rebase COAB instances branches (OPS-manually-rebase-coab-branches)
[//]: # (TODO post-merge - rebase COAB instances branches)

1. See procedure at https://github.com/orange-cloudfoundry/paas-templates/issues/304 to be applied on paas-template repository  
You can also use `admin/rebase-paas-templates-branches.sh` script

    ```
    cd ~/bosh/template/admin
    ./rebase-paas-templates-branches.sh -s reference -b "*serviceinstances" -f -p <gitlab_url>
    ```

### Rebase custom branches (OPS-manually-rebase-custom-branches)
[//]: # (TODO post-merge - rebase custom branches)

1. You can use `admin/rebase-paas-templates-branches.sh` script, without `-b ...` (it will process all feature branches except one containing `coab`)

    ```
    cd ~/bosh/template/admin
    ./rebase-paas-templates-branches.sh -s reference -f -p <gitlab_url>
    ```

2. Manually trigger `sync-feature-branches/jobs/apply-merged-wip-features-reset` if `sync-feature-branches/jobs/update-merged-wip-features` is still failing

3. When every COAB and custom branches are rebased, trigger `paas-templates-xx-upgrade/OPS-manually-rebase-coab-branches` and `paas-templates-xx-upgrade/OPS-manually-rebase-custom-branches`

### Check and fix updated secrets (OPS-manually-check-and-fix-updated-secrets)
[//]: # (TODO pre-upgrade - Check and fix updated secrets, and apply manual steps)

>**Note**:  
> During automatic upgrade comments in secrets files are **LOST** (if you want to keep them, use following syntax)

```
  site_comment: "#--- Tenant identification"
  site: fe-prod

  #--- Bosh directors
  bosh_comment: "#--- Bosh directors"
  bosh:
```

Most secrets updates are automated (see `Pipeline Automated` tag on each manual ops step), but some of them still requires manual updates  

1. During upgrade process, some secrets key are initialized, but you have to set the associated value  
You can identify secrets that need to be set with following command (from `docker-bosh-cli`)

    ```
    cd ~/bosh/secrets
    git pull --rebase
    f "FIXME - REQUIRED" | grep -v "/coa/pipelines"
    ```

2. Ensure that a Github access token `bot-github-access-token` is provided in `~/bosh/secrets/coa/config/credentials-git-config.yml`

    ```
    grep bot-github-access-token ~/bosh/secrets/coa/config/credentials-git-config.yml
    ```

    If missing, you need to : 
    - Visit `https://github.com/settings/tokens` as an authenticated github user,
    - Generate a new token: 
        * Set note to "Used by COA to get github releases", and does not select anything
        * Click `generate token` at bottom
        * Save the token and set it to  `bot-github-access-token` in `~/bosh/secrets/coa/config/credentials-git-config.yml`, then commit and push to repository  
          By default, this token has only `public_repo` scope

3. Check if your token is valid

    ```
    proxy
    export GITHUB_TOKEN="<YOUR_GENERATED_TOKEN>" ; curl -is https://api.github.com/zen -H "Authorization: token ${GITHUB_TOKEN}" | grep -E "^X-RateLimit"
    proxy
    ```

    Result is `X-RateLimit-Limit` set to `5000`

4. Check Release Note to apply features related credentials/operations steps in `Pre-upgrade steps` sections, then commit and push updates to repository (if needed)

5. When secret are set and pushed, you can trigger `paas-templates-xx-upgrade/jobs/OPS-manually-check-and-fix-updated-secrets`

### Recreate micro-bosh (manual-step-recreate-micro-bosh)

1. Trigger `manual-step-recreate-micro-bosh` job, wait it turns green and check that micro-bosh is well recreated

2. Trigger `OPS-manually-ensure-micro-bosh-recreation-is-successfull`

### Update concourse (step-9-upgrade-micro-depls-concourse)

1. Unpause the job `paas-templates-xxx-upgrade/jobs/step-9-upgrade-micro-depls-concourse`, and wait it turns green before next step

### Update other micro-depls deployments (manual-step-10-upgrade-micro-bosh-deployments)

1. Trigger `paas-templates-xxx-upgrade/manual-step-10-upgrade-micro-bosh-deployments` job and wait it turns green before next step

### Check and fix micro deployments (OPS-manually-check-and-fix-micro-bosh-deployments)

1. Check that all `micro-depls` deployments are well deployed in `micro-depls-bosh-generated` pipeline

2. Trigger `OPS-manually-check-and-fix-micro-bosh-deployments` job and wait it turns green before next step

### Check and fix master deployments (OPS-manually-check-and-fix-master-bosh-deployments)

1. Check that all `master-depls` deployments are well deployed in `master-depls-bosh-generated` pipeline

2. A dependency between `isolation-segment-intranet-*` and `cf` deployments is not orchestrating by update pipeline and may generate deployments error  
These deployments may require manual retriggering to achieve.

3. Shield job registration is now performed by errand, automatically scheduled by concourse (`run-errand-<deployment-name>-shield-provisioning`)  
Unfortunately, errors triggering during this errands are masked and the errand turns green  
Manually check individual concourse job errands to catch error messages

4. Trigger `OPS-manually-check-and-fix-master-bosh-deployments` job and wait it turns green before next step

### Deploy remaining deployments (manual-step-12-upgrade-remaning-root-deployments)

1. Trigger `manual-step-12-upgrade-remaning-root-deployments` job and wait it turns green before next step

    >**Note**:  
    > Deployments in `coab-depls-bosh-generated` stay paused to allow operator to control when they want to manually unpause them

2. Check that all deployments are well deployed in following pipeline
- `ops-depls/ops-depls-bosh-generated`
- `ops-depls/ops-depls-cf-apps-generated`
- `coab-depls/coab-depls-bosh-generated`
- `remote-r2/remote-r2-depls-bosh-generated`
- `remote-r3/remote-r3-depls-bosh-generated`

3. Trigger `OPS-manually-check-and-fix-remaning-root-deployments` job and wait it turns green before next step

### Check that all terraform jobs have been applied

1. Trigger (if needed) following jobs

- `micro-depls/pipelines/micro-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`
- `master-depls/pipelines/master-depls-bosh-generated/jobs/approve-and-delete-disabled-deployments`
- `ops-depls/pipelines/ops-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`
- `coab-depls/pipelines/coab-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`

### Clean up (step-13-cleanup)

1. Check Release Note to apply features related credentials/operations steps in `Post-upgrade steps` sections, then commit and push updates to repository (if needed)

2. Manually trigger `paas-templates-xxx-upgrade/jobs/step-13-cleanup` job to clean up bosh deployments

3. Manually trigger `paas-templates-xxx-upgrade/jobs/step-13-cf-clean-scripts` job to clean up cf apps deployments

### Upgrade pipelines cleanup

1. Check Release Note to apply features related credentials/operations steps in `Clean-up steps` sections, then commit and push updates to repository (if needed)

2. Once all upgrade process ended, destroy upgrade pipelines (`init-upgrade-pipelines`, `coa-v4.*-upgrade` and `upgrade-to-paas-templates-*`)  
by using `execute-this-to-destroy-this-pipeline-once-upgrade-is-complete` jobs