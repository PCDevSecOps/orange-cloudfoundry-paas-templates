

# Releasing a new version

This section describes how paas-templates maintainers qualify and generate new paas-templates release.

Naming conventions: examples in this procedure take the example of a new v41 version (also referred to as v+1)

* stay on fe-int unless v+1 modifs gets merged into develop then switch to fe-dev 
* assess the status of the fe-dev environment, in the associated orange private etherpad `suivi-fe-dev`
   * record the state of prometheus alerts (such as saving the alerts webpage on disk)
   * record the state of the concourse pipeline (such as saving the concourse dashboard status)  
* tag the secret repo with current version: 

```sh
git tag -a v40 -m "Snapshot of secrets state before starting v41 installation"
```

* pause all pipelines
* prepare the `update-paas-templates-release` step:
   * connect to gitlab with root account using standard IDP (i.e. not ldap IDP)
   * on the repository settings/repository/protected branches menu, unprotect the `reference` (default)   
* from a desktop machine (or bosh-cli account) apply the script available in orange private gitlab forge https://gitlab.forge.redacted.com/skc-cloudfoundry/kb/blob/master/git/update-paas-templates-release.sh which creates a fix branch and update paas-templates on the local gitlab
* finalize the `update-paas-templates-release` step:
   * connect to gitlab with root account using standard IDP (i.e. not ldap IDP)
   * on the repository settings/repository/protected branches menu, protect the `reference` (default) granting `Maintainers` group permissions to merge and push 
* unpause `sync-feature-branches` and `control-plane` pipelines
* trigger `sync-feature-branches/reset-merged-wip-features` job to make sure the feature branches merge on updated reference branch. Check the displayed `paas-templates-reference` repo matches the RC tag

* prepare fe-dev secrets by applying the release notes
* if necessary contribute fixes into the fix branch (e.g. `feature-fix-v41.0.0-RC2`)
* tag new RC on fe-dev
* repeat the process above with new RC
* once fe-dev is final, create a merge request on FE-int + handle potential conflicts with v+2


