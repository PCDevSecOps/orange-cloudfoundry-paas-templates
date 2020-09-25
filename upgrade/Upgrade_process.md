# Paas-template upgrade process


## Overview
![Alt text](https://g.gravizo.com/source/upgrade_process_principles?https%3A%2F%2Fraw.githubusercontent.com%2Forange-cloudfoundry%2Fpaas-templates%2Fmanual-drop%2Fupgrade%2Fupgrade_process_principles.puml)
<details> 
<summary>Upgrade process principles</summary>
</details>

## Conventions

- If Concourse job begins with `manual-step-`, you need to manually trigger it to execute associated automated tasks (it's a breakpoint within upgrade process)
  >**Note:**  
  > Be careful, some `manual-step-xx` jobs are not well displayed in concourse webui (sometimes in left position from the current job).  
  > You can identify jobs execution order whith their names (e.g: `manual-step-10-upgrade-micro-bosh-deployments`)

- If Concourse job begins with `trigger-AFTER-`, it requires manual external tasks/checks before triggering it
  >**Note:**  
  > In case of `trigger-AFTER-applying-*`, you have to check and apply manual tasks described in relase note

- Upgrade pipeline is split in various chronological tabs:
  * overview: display all steps
  * pre-compile: regroup steps related to pre-compilation
  * pre-merge: regroup steps acting on paas-template not yet updated
  * pre-upgrade: regroup steps around `pre-upgrade` (like secrets migration)
  * setup-pipelines: update status of various pipelines
  * micro-depls: regroup steps related to micro-depls
  * other-depls: regroup steps related to remaining root deployment (ie: all except micro-depls)
  * multi-region: regroup steps related to multi-region (VPN, etc...), requiring custom orchestration 
  * post-upgrade: regroup steps related to post-upgrade (automated non destructive operations)
  * cleanup: regroup steps related to clean-up, usually with manual execution
  * utils: regroup utility steps (like pause/unpause, list bosh releases and stemcells per root deployment, etc...)

## Load upgrade pipelines (coa and paas-template) from pre-install branch

>**Note:**  
> For next operations, ensure you pushed your previous updates (if exists) in each repository before deleting directories

1. Set pre-requisites on `operator local env` (your laptop)

- `~/bosh/secrets` => Up to date `secrets` clone from `target repository` you want to upgrade

  ```
  cd ~/bosh
  rm -fr secrets
  git clone <target_secrets_repo_url> secrets
  ```

- `~/bosh/template` => Up to date `paas-template` clone from `reference repository` ([Paas-Template-Private](https://github.com/orange-cloudfoundry/paas-templates-private)) containing **tagged version** to install

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

5. If exists, destroy previous upgrade pipeline by using `execute-this-to-destroy-this-pipeline-once-upgrade-is-complete` job in obsolete pipeline

6. Ensure concourse jobs from `main/init-upgrade-pipelines` pipeline turn green before operating next step  
You may need to retrigger `display-meta-inf` job, if previous update pipeline was not cleaned up  
Check branch name is valid in the inputs of `reload-this-pipeline-from-git` and matches the pre-install branch name (version to install)

## Bump Cf-Ops-Automation (with coa-vxxx-upgrade concourse pipeline)

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

2. Bump `cf-ops-automation` to `5.0.0` version on `gitlab` to your target environment (if needed)

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
    git reset --hard v5.0.0
    gitlog
    git remote add gitlab '<coa_gitlab_repo_url>'
    git push -f --tags gitlab master
    ```

3. Ensure concourse jobs (in `main` team) from `init-upgrade-pipelines` pipeline turn green before operating next step (`display-meta-inf` may need to be retriggered manually to turn green, if the update pipeline from previous version was not cleaned up)

4. Trigger `WARNING-This-pipeline-updates-secrets-repository` concourse job, and ensure steps turn green before operating next step

    If some concourse jobs turn orange (error due to race condition between builds triggered shared/secrets, and COA updated pipelines), then trigger manually failed jobs

    > Errors that can be observed in `master-depls-bosh-generated/jobs/cloud-config-and-runtime-config-for-master-depls`  
    > task config 'cf-ops-automation/concourse/tasks/bosh_update_cloud_config.yml' not found

## Auto start bosh release pre-compilation

Starting with Cf-Ops-Automation 5.0.0, to speed-up release installation, and reduce end-user downtime, we include a pre-compilation step. This ensures bosh releases are already compiled before being used by a deployment.   
Pre-compilation automatically starts when `pre-install-v<tag_version>` is updated.

To disable pre-compilation, add the following key to `~/bosh/secrets/private-config.yml` (create ths file when missing):
```yaml
precompile-mode: false # COA default: true. Set to false to disable pre-compilation
```

## Bump paas-template (with paas-templates-vxxx-upgrade concourse pipeline)

  >**Note:**  
  > During this step, some jobs are paused in the different pipelines to allow upgrade process  
  > Pausing pipelines induces on demand service provisioning unavailability (eg: new COAB services can't be created while concourse is paused. They will fail with a user-facing timeout)

### Synchronize local gitlab with new paas-template release

1. Check `pre-compile`  
    1.1 ensure `pre-compile` step from `upgrade-pipeline`
    1.2 ensure jobs from `<root-deployment>-bosh-precompile-generated` pipelines turn green

2. Trigger `WARNING-This-pipeline-updates-secrets-repository` job from `pre-merge` tab, and ensure automated steps turn green before operating next step

3. Unprotect `reference` branch on `gitlab` before triggering following job. Connect to gitlab and use menu `Settings->Repository->Protected Branches`

4. Trigger `manual-step-create-fix-branch-only-once` job and wait it turns green

5. Check Release Note to apply features related credentials/operations defined in `Pre-merge steps` sections, then commit and push updates to repository (if needed)

6. Trigger `trigger-AFTER-applying-pre-merge` job and wait it turns green

7. Protect back the `reference` branch in gitlab (`no-one` allow pushing nor merging)

8. Check that `reset-paas-templates-WIP-to-reference` job turns green

### Rebase COAB instances branches

1. Use `admin/rebase-paas-templates-branches.sh` script to rebase COAB instances branches

    ```
    cd ~/bosh
    git remote -v
    ~/bosh/template/admin/rebase-paas-templates-branches.sh -r <template_gitlab_url> -s reference -b "*serviceinstances" -f
    ```

2. Trigger `trigger-AFTER-rebasing-coab-branches` job when COAB instances branches are rebased with no conflicts

### Rebase custom branches

1. Use `admin/rebase-paas-templates-branches.sh` script (no conflicts before next step), without `-b ...` (it will process all feature branches except those containing `coab`)

    ```
    cd ~/bosh
    git remote -v
    ~/bosh/template/admin/rebase-paas-templates-branches.sh -r <template_gitlab_url> -s reference -f
    ```

2. Trigger `trigger-AFTER-rebasing-custom-branches` when custom branches are rebased with no conflicts

### Check and fix updated secrets

>**Note**:  
> During automatic upgrade comments in secrets files are **LOST** (if you want to keep them, use following syntax)

```
  site_comment: "#--- Tenant identification"
  site: fe-prod

  #--- Bosh directors
  bosh_comment: "#--- Bosh directors"
  bosh:
```

Most secrets updates are automated (see `Pipeline Automated` tag on each manual ops step), but some of them still require manual updates  

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
    export GITHUB_TOKEN="$(grep "bot-github-access-token" ${HOME}/bosh/secrets/coa/config/credentials-git-config.yml | awk '{print $2}')" ; curl -is https://api.github.com/zen -H "Authorization: token ${GITHUB_TOKEN}" | grep -E "^X-RateLimit"
    proxy
    ```

    Result is `X-RateLimit-Limit` set to `5000`

4. Check Release Note to apply features related credentials/operations steps in `Pre-upgrade steps` sections, then commit and push updates to repository (if needed)

5. When secret are set and pushed, you can trigger `trigger-AFTER-applying-pre-merge` job

6. Check that all automated jobs in `setup-pipelines` step turn green

### Recreate micro-bosh

1. Trigger `manual-step-recreate-micro-bosh` job and wait it turns green 

2. Check that micro-bosh is well recreated and then trigger `trigger-AFTER-ensuring-micro-bosh-recreation-is-successfull`

### Update micro-depls deployments

1. When main micro-depls deployments are deployed, trigger `manual-step-10-upgrade-micro-bosh-deployments` job and wait it turns green before next step

2. Check that all `micro-depls` deployments are well deployed in `micro-depls-bosh-generated` pipeline

3. When all `micro-depls` deployments are well deployed, trigger `trigger-AFTER-checking-and-fixing-micro-bosh-deployments` job and wait it turns green before next step

### Update master-depls deployments

1. Check that all `master-depls` deployments are well deployed in `master-depls-bosh-generated` pipeline

2. A dependency between `isolation-segment-intranet-*` and `cf` deployments is not orchestrating by update pipeline and may generate deployments error  
These deployments may require manual retriggering to achieve

3. Shield job registration is now performed by errand, automatically scheduled by concourse (`run-errand-<deployment-name>-shield-provisioning`)  
Unfortunately, errors triggering during this errands are masked and the errand turns green  
Manually check individual concourse job errands to catch error messages

4. When all `master-depls` deployments are well deployed, trigger `trigger-AFTER-checking-and-fixing-master-bosh-deployments` job and wait it turns green before next step

### Update remaining deployments

1. Trigger `manual-step-12-upgrade-remaning-root-deployments` job and wait it turns green before next step

    >**Note**:  
    > Deployments in `coab-depls-bosh-generated` stay paused to allow operator to control when they want to manually unpause them

2. Check that all deployments are well deployed in following pipeline
- `ops-depls/ops-depls-bosh-generated`
- `ops-depls/ops-depls-cf-apps-generated`
- `coab-depls/coab-depls-bosh-generated` (if you manually unpause the pipeline)
- `remote-r2/remote-r2-depls-bosh-generated`
- `remote-r3/remote-r3-depls-bosh-generated`

3. When all other deployments are well deployed, trigger `trigger-AFTER-checking-and-fixing-remaining-root-deployments` job and wait it turns green before next step

### Post-upgrade

1. Trigger (if needed) following terraform jobs

- `micro-depls/pipelines/micro-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`
- `master-depls/pipelines/master-depls-bosh-generated/jobs/approve-and-delete-disabled-deployments`
- `ops-depls/pipelines/ops-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`
- `coab-depls/pipelines/coab-depls-bosh-generated/jobs/approve-and-enforce-terraform-consistency`

2. Check Release Note to apply features related credentials/operations steps in `Post-upgrade steps` sections, then commit and push updates to repository (if needed)

3. When tasks applied, trigger `trigger-AFTER-applying-post-upgrade` job

### Cleanup

1. Trigger `manual-step-13-cleanup` job to clean up bosh deployments

2. Trigger `manual-step-13-cf-clean-scripts` job to clean up cf apps deployments

3. Check Release Note to apply features related credentials/operations steps in `Clean-up steps` sections, then commit and push updates to repository (if needed)

4. When all task applied, trigger `trigger-AFTER-applying-cleanup` job

5. Once all upgrade process ended, destroy upgrade pipelines (`init-upgrade-pipelines`, `coa-vxxx-upgrade` and `paas-templates-xxx-upgrade`)  
by using `execute-this-to-destroy-this-pipeline-once-upgrade-is-complete` job

6. Add a tag on secrets repository

  ```
  cd ~/bosh/secrets
  git tag <tag_version>
  git push origin <tag_version>
  ```

7. Delete `pre-install-v<tag_version>` branch

  ```
  cd ~/bosh/template
  git checkout reference
  git br -D pre-install-v<tag_version>
  git push origin --delete pre-install-v<tag_version>
  ```