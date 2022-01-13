
## Overview

This directory holds a bash-based library of functions used to deploy and test service brokers

<!-- TOC initiated with [gh-md-toc](https://github.com/ekalinin/github-markdown-toc) -->
<!--ts-->
   * [Overview](#overview)
   * [Operating brokers with the library](#operating-brokers-with-the-library)
      * [Deployment](#deployment)
      * [Release or tarball broker source](#release-or-tarball-broker-source)
      * [Broker registration](#broker-registration)
         * [Purging service offerings](#purging-service-offerings)
      * [Service plan visibility](#service-plan-visibility)
      * [OSB smoke tests](#osb-smoke-tests)
         * [Org used to instanciate service instances](#org-used-to-instanciate-service-instances)
         * [Service instance and service key provisionning](#service-instance-and-service-key-provisionning)
         * [Custom assertion functions](#custom-assertion-functions)
         * [Default service instance assertions](#default-service-instance-assertions)
         * [Default service binding assertions](#default-service-binding-assertions)
         * [Default service key and service binding assertions](#default-service-key-and-service-binding-assertions)
      * [K8S svcat smoke tests](#k8s-svcat-smoke-tests)
      * [Turn on debugging mode](#turn-on-debugging-mode)
      * [Hijacking into contains from a failed/running concourse container](#hijacking-into-contains-from-a-failedrunning-concourse-container)
   * [Authoring brokers using the library](#authoring-brokers-using-the-library)
      * [Bumping coa brokers on common broker script changes](#bumping-coa-brokers-on-common-broker-script-changes)
      * [Updating coa instances with new libs](#updating-coa-instances-with-new-libs)
   * [Contributing to the library](#contributing-to-the-library)
      * [Bash resources](#bash-resources)
      * [Saving interactively testing hot fixes into git](#saving-interactively-testing-hot-fixes-into-git)
      * [Configuring IDEs](#configuring-ides)
         * [Intellij IDEA](#intellij-idea)
      * [Design notes](#design-notes)
         * [Current design](#current-design)
         * [Issues and smells](#issues-and-smells)
         * [Future requirements:](#future-requirements)
         * [Possible refactoring steps](#possible-refactoring-steps)
<!--te-->

## Operating brokers with the library

### Deployment

### Release or tarball broker source

During development, the broker jar artefact may be pulled from the ephemeral tarballs produced CI/CD associated with feature branch being tested

```yaml
  # in release mode (the default), versionned artefacts are fetched for paas-templates reference
  mode: release
```


```yaml
  # in tarball mode (optin), the artefacts are fetched from ephemeral tarballs produced CI/CD associated with feature branch being tested 
    mode: tarball
    tarball_branch: issue-108-osb-context-annotations
```


### Broker registration

Service broker can optionally be registered with master-depls/cf with the specified broker name. When a broker with the same name exists, then the `cf update-service-broker` command is used

```yaml
  # Optionally turn on broker registration. Default is false.
  register_broker_enabled: true
  #name of the broker to register in marketplace
  broker_name: osb-cmdb-broker-0 

  # Broker username and password may be configured explicitly
  # Some paas-templates deployments automate credentials management using credhub.
  osb-reverse-proxy-1: # should be matching paas-templates coa deployment name
    name: "admin"  # broker basic auth user name. 
    # Default is fetch from shared/secrets.yml with path /secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password
    password: "redacted_password" 

```

#### Purging service offerings

As a workaround for overview broker used as a test broker whose catalog changes after each restart, see https://github.com/cloudfoundry/overview-broker/issues/71, the following property will trigger a `cf purge-service-offering -f "${s}" -b "${BROKER_NAME}"` command on **integration** platforms only
```
  register_broker_dangerously_purge_service_offerings: false
```

### Service plan visibility

By default, no service plans are visible in master-depls/cf.
For some service offerings, all associated service plans can optionally be made visible to a set of organizations. 
It is not yet possible to manage visibility of a single service plan

```yaml
  # List of service offerings to make visible in orgs
  # All associated service plans will be made visible.
  register_broker_services: "mariadb-shared noop-ondemand mariadb-dedicated redis-dedicated"
  # List of orgs to make service offering visible.
  # org used in smoke tests is automatically added to this list
  enable_services_in_orgs: "system_domain acdc-demo-iaas-consumption-sosh-care"
```

### OSB smoke tests

#### Org used to instanciate service instances

Smoke tests provision a service instance in the specified org, in a space automatically provisionned. There is no yet configuration option to tune the space name.

```yaml
  # org to be used by smoke tests. Will be created automatically by common broker scripts if missing
  smoke_test_org: osb-cmdb-brokered-services-org-client-0 
```

#### Service instance and service key provisionning

```yaml
  #name of the service to instanciate in smoke tests
  smoke_test_service: "mariadb-dedicated"
  #name of the service plan to instanciate in smoke tests
  smoke_test_service_plan: "small"

  # service instance arbitrary params content. No params by default.
  service_instance_configuration_parameters: |
    {
      "rainbow": true,
      "name": "my string",
      "color": "green",
      "config": {
        "url": "https://url.com",
        "port": 3128
      }
    }

  # service key arbitrary params content. No params by default.
  service_key_configuration_parameters: |
    {
      "read-only": true
    }

```

#### Custom assertion functions

The following functions are called with the following arguments if defined

```bash
assert_create_service_instance "${SERVICE_INSTANCE}"
assert_create_service_key "${SERVICE_INSTANCE}" "mykey"
assert_delete_service_key "${SERVICE_INSTANCE}" "mykey"
assert_delete_service_instance "${SERVICE_INSTANCE}" "${SERVICE_INSTANCE_GUID}"
assert_broker_actuator_endpoints # called at the end of the OSB lifecycle assertions
```

To define a custom assertion, declare the associated property in the corresponding secrets.yml file. This will be wrapped into a bash function declaration. Consequently, you should declare local variables using the local keyword, and return a 0 exit status for success or 1 exit status for failures. Stdout and stderr can be used to display diagnostic messages. The [common broker script helper functions](https://github.com/orange-cloudfoundry/paas-templates/tree/manual-drop/coab-depls/common-broker-scripts) and variables can be used in addition of function arguments.

```yaml
secrets:
[...]
  # defines a function to assert the create service instance
  # $1: service instance name
  # will fail on any non zero exit status, (eg. "false" command)
  # hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
  assert_create_service_instance: |
    echo_header "asserting that the underlying broker (assuming overview-broker from paas-templates) recorded OSB calls were proxied by intranet proxy"
    ...
```

Real world example of custom assert
```yaml
  # defines a function to assert the create service instance outcome
  # $1: service instance name
  # will fail on any non zero exit status, (eg. "false" command)
  # hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
  assert_create_service_instance: |
    echo_header "asserting that the underlying broker (assuming overview-broker from paas-templates) recorded OSB calls were proxied by intranet proxy"
    TEST_BROKER_URL="https://overview-broker."$(bosh int "${SHARED_SECRETS}" --path /secrets/cloudfoundry/system_domain)
    #Note: can't use the BROKER_URL (i.e. osb-reverse-proxy.internal-controlplane-cf.paas) because only v2/** requests are authorized by osb-reverse-proxy
    assert_curl_returns_200 -u "admin:password" ${TEST_BROKER_URL}/dashboard
    #cat /tmp/curlResponseOutput | grep x-forwarded-for
    # expecting (more recent requests first):
    #     <span class="key">"x-forwarded-for":</span> <span class="string">"192.168.35.70, 192.168.35.50,192.168.35.70, 10.228.194.10"</span>,
    #...
    local x_forwarded_for=$(cat /tmp/curlResponseOutput | grep x-forwarded-for | cut -d "\"" -f8 | head -n1)
    # expecting with bosh intranet proxy:
    #192.168.35.70, 192.168.35.50,192.168.35.70, 10.228.194.10
    # expecting with k8s intranet proxy: (10.228.198.16x are 00-core-connectivity-k8s/agents)
    #192.168.35.70, 192.168.35.50,192.168.35.70, 10.228.198.164
    #Inspiration from https://unix.stackexchange.com/a/20793/381792
    local proxy_ip_address=$(getent hosts intranet-http-proxy.internal.paas | awk '{ print $1 }')
    echo "x-forwarded-for for last request is: ${x_forwarded_for}"
    echo "intranet proxy K8S ip address is: ${proxy_ip_address}"
    echo "however, 00-core-connectivity-k8s/agents outgoing IP addresses are hardly predicatable automatically: 10.228.198.16[3,4,6,7]"
    # check XFF ends with the proxy ip address
    # ie regular expression with the $ specifying end of line
    echo "skipping assertion based on FQDN intranet-http-proxy.internal.paas"
    #    if [[ "${x_forwarded_for}" =~ ${proxy_ip_address}$ ]]; then
    #      echo "osb request properly went through the http proxy."
    #    else
    #      echo "expected osb request to have the proxy as last XFF value. Failing"
    #      false
    #    fi
    echo "instead, testing whether XFF contains 10.228.198.16x from 00-core-connectivity-k8s/agents current addresses"
    if [[ "${x_forwarded_for}" =~ "10.228.198.16" ]]; then
      echo "osb request properly went through the http proxy."
    else
      echo "expected osb request to have the proxy as last XFF value. Failing"
      false
    fi
```

The following screenshot illustrate how to configure intellij IDE to get bash feature in the secret heredoc fragment. ALT+Enter to show intention

![image](https://user-images.githubusercontent.com/4748380/96151908-39e0f380-0f0c-11eb-8e40-045cabdb5395.png)
Inject language reference, and select bash language
![image](https://user-images.githubusercontent.com/4748380/96152423-d4413700-0f0c-11eb-8311-584dc64da4de.png)

get syntax highlighting, completion, static code analysis

![image](https://user-images.githubusercontent.com/4748380/96152083-6d238280-0f0c-11eb-8234-bc7a231b28de.png)


#### Default service instance assertions

```yaml
   # Assert that a service instance dashboard is defined. Default is false  
   assert-dashboard-defined: true

   # Assert that the service instance dashboard return 401 status by default. Default is false  
   assert-dashboard-authenticated: true
```



#### Default service binding assertions

By default, a service binding is created by binding the service instance against a sample probe app.

The probe app is then called with the following not yet configureable settings
```bash
PROBE_ARGUMENT="${PROBE_ARGUMENT:-}"
PROBE_VERB_SETTING="${PROBE_VERB_SETTING:-POST}"
PROBE_VERB_CLEARING="${PROBE_VERB_CLEARING:-DELETE}"
PROBE_URL_CONTEXT="${PROBE_URL_CONTEXT:-myTable}"

# Check related source code at invoke_service_probe() for more details
```

```yaml
  #Define the internet-facing git repo to clone from
  # Default is "https://github.com/orange-cloudfoundry/cf-${COAB_SERVICE}-example-app"
  service_probe_app_git_repo_url: "https://github.com/orange-cloudfoundry/my-sample-app"
  
  # The tag or branch to checkout on the sample app git repo. Default is "coab"
  service_probe_app_git_tag: "my-custom-tag"
```
```yaml
  #an empty SERVICE_PROBE_APP_GIT_REPO_URL or value "none" requires skipping app tests.
  service_probe_app_git_repo_url: "" #disable service probe when testing with service offering without available probe
```

```yaml
# defines a function to assert the created service key
# $1: service instance name
# $2: service key name
# will fail on any non zero exit status, (eg. "false" command)
# hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
assert_create_service_key: |
                             echo_header "asserting that ..."
  if [[ ... ]]; then
  echo "success"
  else
  echo "expected ..., Failing"
  false
  fi

```
#### Default service key and service binding assertions

### K8S svcat smoke tests

In addition to testing against CF CLI, smoke tests can assert against Kubernetes service catalog CLI
```yaml
    # Enable smoke tests to exercise svcat client. Default is "false".
    # Will create a namespace into the paas-templates K8S cluster (micro-depls/gitops-management by default) whose name
    # is named after the concatenation of the `smoke_test_org` property and the `smoke_test_space`
    smoke_test_k8s_service_catalog_client: true
```

### Turn on debugging mode

Operators or authors can choose to turn on debugging traces in their broker secrets.yml file with a `debug` property

```yaml
secrets:
  debug: false # controls pre-cf-push and post-deploy debug traces
```



### Hijacking into contains from a failed/running concourse container

* log into bosh-cli
* log-fly and the select the root deployment associated with your broker deployment 
* fly hijack -u <concourse-failed-build-url> /bin/ash
* edit secrets/templates files as needed
* rerun push task by running `scripts-resource/scripts/cf/push.sh` command  
* rerun pos-deploy task by running `scripts-resource/concourse/tasks/post_deploy/run.sh` command  

## Authoring brokers using the library

### Bumping coa brokers on common broker script changes

See [commit-and-bump-shared-content.sh](commit-and-bump-shared-content.sh) script.

### Updating coa instances with new libs

This snippet copies a symlink crafted manually in a broker into other brokers. 

``` 
~/code/paas-templates/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/template$ (feature-coab-v49) 
for b in ../../coa-*; do 
    cp -P -a coab-post-deploy-defaults.bash $b/template/
    ls -al $b/template/coab-post-deploy-defaults.bash; 
done
```

## Contributing to the library

### Bash resources

* [Bash Guide for Beginners](http://tldp.org/LDP/Bash-Beginners-Guide/html/index.html)
* Bash manual
   * [TOC](https://www.gnu.org/software/bash/manual/html_node/index.html#SEC_Contents)
   * [indexes](https://www.gnu.org/software/bash/manual/html_node/Indexes.html#Indexes)
* [Advanced bash scripting](https://www.tldp.org/LDP/abs/html/index.html) 
* http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html
* http://mywiki.wooledge.org/BashGuide

### Saving interactively testing hot fixes into git

See [commit-and-bump-shared-content.sh](./commit-and-bump-shared-content.sh) sample helper script to push into paas-templates locally made changes to prepare a branch.

### Configuring IDEs

#### Intellij IDEA

The following plugins are recommended to author the library:
* [BashSupport](https://plugins.jetbrains.com/plugin/4230-bashsupport): provides code structure navigation, refactoring variable names and functions 
* [ShellCheck](https://plugins.jetbrains.com/plugin/10195-shellcheck/): provides static code analysis and hints for common bash pitfalls
   * See https://github.com/koalaman/shellcheck/wiki/Directive for ignoring some rules
   * Each individual ShellCheck warning has its own wiki page like [SC1000](https://github.com/koalaman/shellcheck/wiki/SC1000). Use GitHub Wiki's "Pages" feature above to find a specific one, or see [Checks](https://github.com/koalaman/shellcheck/wiki/Checks).
* The built-in shell script support as of Nov 2019 
   * is incompatible with above plugins. See [about-bashsupports-future](https://discuss.bashsupport.com/t/about-bashsupports-future/27) and [shellcheck-plugin archival status](https://github.com/pwielgolaski/shellcheck-plugin/)
   * does not yet provide feature parity (in particular code navigation/refactorings)
   * only provides [explainshell.com](https://explainshell.com) integration as added value.     
   * related references:
      * https://blog.jetbrains.com/idea/2019/06/intellij-idea-2019-2-eap2-shell-script-support-improved-code-duplicates-detection-services-tool-window-and-more/
      * https://confluence.jetbrains.com/display/IDEADEV/IntelliJ+IDEA+2019.3+EAP+(193.4386.10+build)+Release+Notes?_ga=2.221028376.1222433377.1572274763-516553244.1379058686


### Design notes

#### Current design

2 hooks: 
* pre-cf-push
* post-deploy.sh

* test suite parameters defined as 
   * global variable names
   * optional documentation as comments before variable declaration
   * global variable default constructors
* common-library of bash functions
  * functions with 
    * arguments
    * stdout as return values
    * read global variables

#### Issues and smells

* hard to identify test suite parameters and their behavior
* test suite parameters can potentially be modified by error (as global variables) making tests fragile
* bash syntax is sometimes tricky


#### Future requirements:
* flexibility to move codebase outside of COA bosh-based framework, in K8S CI/CD framework such as ArgoWorkflow
  * different configuration injection mechanisms 
    * currently:
       * secrets repo with 
          * shared/secret.yml
          * deployment/secret.yml
       * credhub hosted secrets
  * binaries dependencies are declarative
    * and bundled/packaged as an OCI image
  *   
* ability to contribute/modify the codebase without running the full test in E2E environment
  * a reference environment which to run the test suite
     * a live CF instance + a reference OSB broker implementation
     * a set of recorded cf cli mock outputs to refactor the test suite offline ?
    
#### Possible refactoring steps

* [ ] make test parameter read-only variables
* [ ] wrap some **selected** test parameters into function arguments to support looping ?
   * Q: use named parameters in functions ?
     * https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash
     * https://www.linkedin.com/pulse/command-line-named-parameters-bash-karthik-bhat-k/?published=t
     * A: seems too verbose
* [ ] replace scalar test parameters with collections, and initialize them with scalars when undefined
  * options 1: individual collections 
   * array into: https://www.artificialworlds.net/blog/2013/09/18/bash-arrays/
   * SERVICE -> SERVICES
   * PLAN -> PLANS
   * SERVICE_INSTANCE_CONFIGURATION_PARAMETERS -> SERVICE_INSTANCES_CONFIGURATION_PARAMETERS 
  * [ ] option 2: array of associative arrays (ie list of maps)
   * https://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
   * Q: how to fetch this from yaml definition ?
      * bosh int
        * option 1: fetch number of elements, and then iterate over each element
        * option 2: iterate over array elements from 0 to 1st failure  
        * Q: how to fetch an array size ?
      * gomplate expression:
        * generate bash array initialization string
      * yq/jq  
      * bash yaml parsing
      * migrate/rewrite in another programming language: python, ruby
         * python
            * https://medium.com/capital-one-tech/bashing-the-bash-replacing-shell-scripts-with-python-d8d201bc0989
            * https://github.com/ninjaaron/replacing-bash-scripting-with-python  
            * pbs:
              * missing interpreter into existing COA cf images, + support for offline package management
         * [ ] ruby: 
            * https://www.devdungeon.com/content/enhanced-shell-scripting-ruby
            * present in coa images
            * yaml library built-in available in coa image
              * https://medium.com/@kristenfletcherwilde/saving-retrieving-data-with-a-yaml-file-in-ruby-the-basics-e45232903d94
            * skills available in team (used in upgrade pipelines)
            * reuse a9s framework ?
              * https://github.com/anynines/cf_services_smoke_tests
                 * mostly bash script (better style than common-broker-scripts)
                 * only service instance assertions are written in ruby, leveraging rspec assertions
                  * not yet opensource
                  * many A9S specifics: backup, metrics, consul, sso, security groups
                  * benefits or inspiration
                     * phantomjs for sso test
                     * better assertions for service instances
                     * better assertions for service instances
                     * better test framework: 
                       * test case
                       * Additional file descriptors as debugging channels
            * Steps
              * [ ] Convert bash functions in ruby https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Method_Calls 
              * [ ] Replace "echo" with "puts" 
              * [ ] Replace sourcing syntax http://rubylearning.com/satishtalim/including_other_files_in_ruby.html  
            
```              
$ ruby -v
   ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux-musl]
```

```yaml
  smoke_test_service: "overview-service" #name of the service to instanciate in smoke tests
  smoke_test_service_plan: "small"    #name of the service plan to instanciate in smoke tests

  # defines a function to assert the create service instance
  # $1: service instance name
  # will fail on any non zero exit status, (eg. "false" command)
  # hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
  assert_create_service_instance: |
    echo "hello world"
```
   becomes
```yaml
  smoke_test_cases:
    - name: "case 1"
      service: "overview-service" #name of the service to instanciate in smoke tests
      service_plan: "small"    #name of the service plan to instanciate in smoke tests
      
      skip_create_service_instance: false   
      # defines a function to assert the create service instance
      # $1: service instance name
      # will fail on any non zero exit status, (eg. "false" command)
      # hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
      assert_create_service_instance: |
        echo "hello world"
```

* Inversion of control to support quick iterations of test framework, possibly unit tests
   * 