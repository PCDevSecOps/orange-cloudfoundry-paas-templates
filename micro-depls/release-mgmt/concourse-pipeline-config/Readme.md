# Release management pipeline
This deployment is required on integration environment to ease paas-template release creation.

# Pre-requisites
 - create an empty branch to hold `paas-templates` version, ignore this step if `version` already exists.
    ```bash
    git checkout --orphan version
    ```

 - create `secrets.yml` using template below:
 
```yaml
---
secrets:
  paas-templates-uri: 
  paas-templates-branch: 
  paas-templates-skip-ssl-verification: 
  paas-templates-wip-branch: 

  paas-templates-sanitized-uri:
  paas-templates-sanitized-skip-ssl-verification: 

  private-git:
    username:   # credential_leak_validated 
    password:   # credential_leak_validated
    api-token-comment: |
     Create a new token at https://<gitlab_url>/profile/personal_access_tokens:
        - choose a name
        - add API Scopes (allow Access the authenticated user's API)
    api-token: 

  slack:
    webhook: 
    channel: 

  diod:
    gitlab:
      uri: 
      username:   # credential_leak_validated
      password:   # credential_leak_validated
      skip-ssl-verification: true

  orange-forge:
    gitlab:
      uri: 
      username:   # credential_leak_validated
      password:   # credential_leak_validated
      skip-ssl-verification: true

  github:
    username:    # credential_leak_validated
    password:    # credential_leak_validated
```
