# Concourse
## Installation

Getting connection credentials:
 from bosh-cli:
  - log-credhub
  - credhub g -n /micro-bosh/concourse/local_user


### Spike: embedded version management
We try to replace COA version management by having boshrelease downloaded by bosh director 

### Pro
 * allows multiple products with different versions (like concourse 3.14.1 and concourse 5.2)
 * may defined convention to still use `xxx-depls-version.yml` in priority, instead of defining a

### Cons
 * version not enforced by COA

### Issues
[//]: #proxy (TODO Discuss bosh director internet access through proxy)

 * as SNAT is disabled, we need to change bosh director config to allow internet access =>   

 ==> workaround manually upload required release 
   https_proxy=http://system-internet-http-proxy.internal.paas:3128 curl "https://bosh.io/d/github.com/concourse/concourse-bosh-release?v=5.3.0" -L -o concourse-bosh-release-5.3.0.tgz
   https_proxy=http://system-internet-http-proxy.internal.paas:3128 curl "https://bosh.io/d/github.com/cloudfoundry/postgres-release?v=37" -L -o postgres-release-37.tgz
   https_proxy=http://system-internet-http-proxy.internal.paas:3128 curl "https://bosh.io/d/github.com/cloudfoundry-community/haproxy-boshrelease?v=9.6.0" -L -o haproxy-boshrelease-9.6.0.tgz
   https_proxy=http://system-internet-http-proxy.internal.paas:3128 curl "https://bosh.io/d/github.com/cloudfoundry-incubator/bpm-release?v=1.0.4" -L -o bpm-release-1.0.4.tgz
   bosh upload-release concourse-bosh-release-5.2.0.tgz
   bosh upload-release postgres-release-37.tgz
   bosh upload-release haproxy-boshrelease-9.6.0.tgz
 
 