This directory is for bosh manifest fragments (ops files, vars files) reused across different deployments.
They are simply simlinked from <root-deployment>/<deployment>/template dirs.

NB: to actually trigger a bosh deploy on a file change, the location must be added in <root-deployment>/<deployment>/deployment-dependencies.yml, ie:

```
---
deployment:
  bosh-deployment:
    resources:
      templates:
        extended_scan_path:
        - submodules/bosh-deployment
        - shared-operators/bosh

```
 