
## Overview

This directory holds a bash-based library of functions used to deploy and test service brokers

## Operating brokers with the library

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
