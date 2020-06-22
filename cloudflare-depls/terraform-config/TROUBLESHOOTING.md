This document describes troubleshooting and recovery steps for the on-demand cloudflare domains.

Worst case scenario: 
- the terraform.tfstate gets corrupted/ lost
- the user routes gets unmapped from apps and domains deleted from cloudfoundry.

Recovery strategy: recover from source of truth
- Cloudflare routes: source of truth is the service instances in CF and TF configuration in GIT
- route mappings to apps: source of truth can be recovered by looking at route mapping deletion in CF logs


Recovery steps:

- clear the cloudflare records (using UI) and the terraform.tfstate
- reapply the terraform job through concourse
- recover the route mappings 

### Recover the route mappings

In logs, seach for deleted route entries matching the following type of entries
`
January 11th 2019, 16:41:52.083router
<14>1 2019-01-11T15:41:52.083347+00:00 192.168.35.80 vcap.gorouter.stdout - - [instance@47450 director="bosh-master" deployment="cf" group="router" az="z2" id="7653872f-ccde-4165-969e-65907a7b2420"]  {"log_level":1,"timestamp":1547221312.0831778,"message":"unregister-route","source":"vcap.gorouter.subscriber","data":{"message":"{\"host\":\"192.168.37.75\",\"port\":61020,\"uris\":[\"redacted-route.on.cloudflare.com\"],\"app\":\"7683483e-2060-431a-87ff-03357188aa02\",\"private_instance_id\":\"12c22899-75f5-4b1d-74ad-2830\",\"private_instance_index\":\"0\",\"server_cert_domain_san\":\"12c22899-75f5-4b1d-74ad-2830\",\"isolation_segment\":\"internet_isolation_segment\",\"tags\":{\"component\":\"route-emitter\"}}"}}
`

Copy/paste logs entries into `deleted-routes.txt` file.

Execute the script 

```bash
$ source routes.bash
$ cat deleted-routes.txt | grep gorouter | cut -c118- | sort | sed 's/.*\]\ \(.*\)/\1/' |  jq -c ".data.message | fromjson |  { route: .uris[0], app: .app } "  | sort | uniq | jq -r ' "display_cmd " + .app +" " + .route ' | while read line; do $line; done;```
```

produces the following output:

```
cf t -o <redacted_org_name> -s <redacted_space_name>;cf map-route <redacted_app_name> <redacted_cloudflare_domain>
cf t -o <redacted_org_name> -s <redacted_space_name>;cf map-route <redacted_app_name> <redacted_cloudflare_domain>
cf t -o <redacted_org_name> -s <redacted_space_name>;cf map-route <redacted_app_name> <redacted_cloudflare_domain>
cf t -o <redacted_org_name> -s <redacted_space_name>;cf map-route <redacted_app_name> <redacted_cloudflare_domain>
cf t -o <redacted_org_name> -s <redacted_space_name>;cf map-route <redacted_app_name> <redacted_cloudflare_domain>

```

Execute these commands.