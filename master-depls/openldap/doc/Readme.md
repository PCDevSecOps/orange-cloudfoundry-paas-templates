# LDAP management

## Profils

Paas internal LDAP server contains 3 different profils:
- `admin` for Paas operators admins
- `auditor` for auditors (read-only access to resources) users

## Scopes by use cases

|Use case|Profil|Scopes|
|--------|------|------|
|_Manage ldap users_|`admin`|`scim.write` `scim.read` `scim.userids`|
|_Update my user password_|`admin` `auditor`|`scim.me` `scim.userids`|
|_Manage bosh releases_|`admin`|`bosh.admin`|
|_Access bosh vms with bosh ssh_|`admin`|`bosh.admin`|
|_Get read access to bosh director resources_|`admin` `auditor`|`bosh.read`|
|_Consult/update credhub properties_|`admin`|`credhub.write` `credhub.read`|
|_Create/update CF deployments_|`admin`|`cloud_controller.admin` `cloud_controller.write`|
|_Create/update service broker_|`admin`|`cloud_controller.admin` `cloud_controller.write`|
|_Consult CF deployments_|`admin` `auditor`|`cloud_controller.read` `cloud_controller_service_permissions.read`|
|_Access to Admin UI web interface_|`admin`|`admin_ui.admin`|

>**Note:**  
> You had to change the default pwd "change_it" for default users (**concourse**, **admin-srv** and **auditor**) with `Ldap Admin` web-ui portal

## Accounts management

- Connect to docker-bosh-cli and get paas-template repository

- Get LDAP admin password from ***shared/secrets/secrets.yml*** secrets repository

``` yaml
  ldap:
    root:
      password: xxx
```

### Ldap account creation
- Create LDAP accounts (for each account to create) and affect account to ldap admin group from paas-template repository root directory

``` bash
$ cd master-depls/openldap/scripts
$ create-account.sh
```

### Ldap account deletion
- Delete LDAP accounts (for each account to create) from paas-template repository root directory

``` bash
$ cd master-depls/openldap/scripts
$ delete-account.sh
```
