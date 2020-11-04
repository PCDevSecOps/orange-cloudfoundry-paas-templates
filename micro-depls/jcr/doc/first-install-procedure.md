>##WARNING 
>This product cannot be install without manual step 
Here is the procedure that help to remind how to do that

### Manual platform ops post-install steps
- get password on credhub that will be use by next step:
` credhub get -n /micro-bosh/jcr/jcr_admin_password`

- as mention into https://github.com/orange-cloudfoundry/paas-templates/issues/725
the first deployment requires that concourse job is launch **twice** before see the admin ui

- open a web browser at this url: https://jcr.((/secrets/cloudfoundry_ops_domain))/
To log in 
>note: that the default user password is: admin/password
- set the new password with the password you got from credhub
- sign the eula
- you can skip other param as the errand will set them automaticaly (if you have set the credhub password)
- launch the manual errand to finalize the configuration
Launch the JCR GUI: 
be careful the repoLayoutRef must be set manually to simple-default by using the GUI on each docker remote repository
