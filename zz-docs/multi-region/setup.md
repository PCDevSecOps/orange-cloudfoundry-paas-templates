# principes

## Activation Sequence 
  1. define r2 and r3 COA profiles
  2. define shared-secrets multi-region secrets
      - r1 vpn secrets and interco ips/subnets
      - r2 iaas credentials, vpn secrets and interco ips 
      - r3 iaas credentials, vpn secrets and interco ips
  3. apply/deploy micro-depls/credhub-seeder
  4. activate master-depls/r1-vpn bosh deployment
  5. configure COA remote r2 and r3
  6. activate master-depls/bosh-remote-r2 bosh deployment
  7. activate master-depls/bosh-remote-r3 bosh deployment
  8. setup static routing in each region to use vpn
      - openstack, terraform apply
        - master-depls
        - remote r2
        - remote-r3
        - coab-depls
      - vsphere
        - configure nsx-v dl router for each tenant static routing.
        - check firewall connectivity between vpn peers

## define r2 and r3 COA profiles
In file coa/config/credentials-active-profiles.yml:

```
# Mandatory. List active profiles (comma separated list without spaces)- Example: profile-1,profile-2 
# Default: empty 
profiles: 80-r2-openstack-hws,81-r3-openstack-hws,99-debug-master-depls,99-debug-coab-depls,99-debug-remote-r2-depls,99-debug-remote-r3-depls

#available profiles:
#90-weave-scope
#99-debug-master-depls
#99-debug-ops-depls
#99-debug-coab-depls
#(99-debug-kubo-depls)
#99-debug-remote-r2-depls
#99-debug-remote-r3-depls

```

## Secrets configuration

### Manual platform ops pre-merge steps
- define remote-r2-depls in COA coa/coa-config/credentials-auto-init.yml

```

concourse-remote-r2-depls: concourse-5-for-remote-r2-depls
concourse-remote-r2-depls-target: https://elpaaso-concourse.<ops_domain>
concourse-remote-r2-depls-username: redacted_username
concourse-remote-r2-depls-password: redacted_password
concourse-remote-r2-depls-insecure: "false"

```

- define remote-r3-depls in COA coa/coa-config/credentials-auto-init.yml
```
concourse-remote-r3-depls: concourse-5-for-remote-r2-depls
concourse-remote-r3-depls-target: https://elpaaso-concourse.<ops_domain>
concourse-remote-r3-depls-username: redacted_username
concourse-remote-r3-depls-password: redacted_password
concourse-remote-r3-depls-insecure: "false"
```

- define pipeline credentials in coa/coa-config/credentials-remote-r2-depls-bosh-pipeline.yml:
```
bosh-target: 192.168.99.153
bosh-username: redacted_username
bosh-password: redacted_password #from credhub get -n /bosh-master/bosh-remote-r2/admin_password

#override of credentials iaas specific TBC
#stemcell-main-name: openstack-kvm-ubuntu-xenial-go_agent
#iaas-type: openstack-hws
```

- define pipeline credentials in coa/coa-config/credentials-remote-r3-depls-bosh-pipeline.yml:
```
bosh-target: 192.168.99.156
bosh-username: redacted_username
bosh-password: redacted_password #from credhub get -n /bosh-master/bosh-remote-r3/admin_password

#override of credentials iaas specific TBC
#stemcell-main-name: openstack-kvm-ubuntu-xenial-go_agent
#iaas-type: openstack-hws
```

- init secrets for root-deployment remote-r2-depls remote-r2-depls/ci-deployment-overview.yml

- activate master-depls/bosh-remote-r2/enable-deployment.yml

- (openstack) define remote region secrets:

```
..
  multi_region:
    region_1:
      #wireguard keypair generation: wg genkey | tee privatekey | wg pubkey > publickey
      public_key: xxxxxxxxxxxxxxxxx
      private_key: xxxxxxxxxxxxxxxxx
      vpn_endpoint: 10.228.194.9

    region_2:
      public_key: xxxxxxxxxxxxxxxxx
      private_key: xxxxxxxxxxxxxxxxx
      vpn_interco:
        nats_ip: 10.228.194.3
        blobstore_ip: 10.228.194.4
        
        endpoint: 10.228.199.147
        range: 10.228.199.144/28
        gateway: 10.228.199.145
        reserved: 10.228.199.145-10.228.199.145
        compilation: 10.228.199.146-10.228.199.146
        static: 10.228.199.147-10.228.199.153

      openstack:
        username: redacted_username
        password: redacted_password
        #--- Generated from Flexible Engine Portal
        access_key: redacted_access_key
        secret_key: redacted_secret_key
        #--- Keystone access
        auth_url: https://iam.eu-west-0.prod-cloud-ocb.orange-business.com/v3/
        domain:
          name: OCB8888888
        project:
          name: eu-west-0
          id: xxxxxxxxxxxxxxxxxxxxxxxxx
        tenant:
          name: OCB8888888
          id: xxxxxxxxxxxxxxxxxxxxxxxxx
        region:
          name: eu-west-0
        availability_zone: eu-west-0b

    region_3:
      public_key: xxxxxxxxxxxxxxxxx
      private_key: xxxxxxxxxxxxxxxxx
      vpn_interco:
        nats_ip: 10.228.194.5
        blobstore_ip: 10.228.194.6
        endpoint: 10.228.198.147
        range: 10.228.198.144/28
        gateway: 10.228.198.145
        reserved: 10.228.198.145-10.228.198.145
        compilation: 10.228.198.146-10.228.198.146
        static: 10.228.198.147-10.228.198.153
      openstack:
        username: redacted_usernamename
        password: redacted_password
        #--- Generated from Flexible Engine Portal
        access_key: zzzzzzzzzzzzzzz
        secret_key: zzzzzzzzzzzzzzz
        #--- Keystone access
        auth_url: https://iam.eu-west-0.prod-cloud-ocb.orange-business.com/v3/
        domain:
          name: OCB9999999
        project:
          name: eu-west-0
          id: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        tenant:
          name: OCB9999999
          id: yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
        region:
          name: eu-west-0
        availability_zone: eu-west-0b
```

## troubleshooting

## Troubleshooting vpn instances requires:
- activating COA profiles for debugging
- for openstack, creating a debug vm with a floating ip
  - ssh vcap@<vpn ip>
  - sudo -i + password set by bosh debug profile
  - wg should give wireguard status


## analyzing traffic flow

```
tcpdump  -ennvH -i any |grep 192.168.117
```

