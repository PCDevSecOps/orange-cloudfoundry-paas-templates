Osb-reverse-proxy enables master-depls/cf to reach 3rd party brokers only exposed on intranet/internet

See https://github.com/orange-cloudfoundry/osb-reverse-proxy-spike for more details.

## Usage

- Handles credhub secret generation, broker registration, service plan visibility
and smoke test execution.
- Jar is downloaded from circleci in tarball mode or github in release node,
   preprocessed to replace application.yml
- Smoke tests exercise usual CRUD


### Instance per OSB client

There is one instance of osb-reverse-proxy per Osb client (osb-reverse-proxy-0, ... osb-reverse-proxy-4).
* Per convention, osb-reverse-proxy-0 is dedicated to master-depls-cf osb client
* Per convention, the canoncial template instance (osb-reverse-proxy) is not enabled 

## Contributing

### Updating symlinked instances

The [symlink-osb-reverse-proxy-files.bash](./symlink-osb-reverse-proxy-files.bash) will update all instances, and trigger CI exec of the the canoncial template instance 


$ cf m
Getting services from marketplace in org service-sandbox / space osb-reverse-proxy-0-smoke-tests as xx...
OK
service        plans          description          broker
p-mysql-cmdb   10mb, 20mb     A useful service     osb-reverse-proxy
p-mysql-cmdb   10mb, 20mb     A useful service     osb-reverse-proxy-0
