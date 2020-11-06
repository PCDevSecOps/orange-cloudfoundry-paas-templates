>##WARNING 
>- This doc just concerns a config update.
>- Don't update manually JCR if you do that think about add a note on first install to reflect the change
 
 
### How to do 
- update the `jcr-config-operators.yml file`
to add/remove remote repository and update virtual repository list
see https://www.jfrog.com/confluence/display/JFROG/Artifactory+YAML+Configuration 
to know how to do that.
>Note: specificity for docker remote repository: `enableTokenAuthentication: true` is mandatory
be careful the repoLayoutRef must be set manually to simple-default by using the GUI

### Manual platform ops post-install steps


- launch the manual errand to finalize the configuration

- open a web browser at this url: https://jcr.((/secrets/cloudfoundry_ops_domain))/
To log in and verify  
