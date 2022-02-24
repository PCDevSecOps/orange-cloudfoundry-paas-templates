This is a failed attempt to split the status template into smaller chunks using string templating with variable substitution

This does not work due to line feed removal in substituted variables. 
See https://github.com/fluxcd/flux2/discussions/2211 and https://github.com/fluxcd/kustomize-controller/issues/518


the master-depls/k3s-sandbox/k8s-config/manifests/00-flux-kustomizations contained a kustomization with replacement
and a template with substituted 

```yaml
  # replace status gotemplate fragments
  postBuild:
    # Should reside in the same namespace as the referring resource, i.e. 72-interoperator
    substituteFrom:
      - kind: ConfigMap
        name: pxc-default-plan-status-fragments
 
```

```
patchesJson6902:
## Attempt to split from distinct gotemplate files failed due to linefeed
## removal in substitued variable, see https://github.com/fluxcd/kustomize-controller/issues/518
#- target:
#    group: osb.servicefabrik.io
#    version: v1alpha1
#    kind: SFPlan
#    name: 39d7d4c8-6fe2-4c2a-a5ca-b826937d5a88
#  path: pxc-default-SF-plan-configmap-status-substitutions.yaml 
```