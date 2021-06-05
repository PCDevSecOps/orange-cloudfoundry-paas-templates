# Cloudflare broker

## Overview

The purpose of this deployment is to provision cloudflare Saas subscriptions. This provides users with an internet-facing domain protected by cloudflare DOS prevention, and potentially other features such as analytics, rate limiting. try syntax: cf cs cloudflare default myroute2 -c '{\"route-prefix\":\"myroute2\"}' which should result into a new route without hostname created in the current space. This route needs to be bound applications.

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | CfApp |
| Depends on | [COAB](https://github.com/orange-cloudfoundry/cf-ops-automation-broker) |
| Depends on | [COA 1.6+](https://github.com/orange-cloudfoundry/cf-ops-automation/releases/tag/v1.6.0) |
| Vars files | NA |
| Ops files | NA |

## Architecture

The broker is a Spring Boot application written in Java. It commits in git (paas-secret)terraform modules, and scans the result in terraform.tfstate 

## Tips

Prerequisite: the set up of the cloudflare deployments terraform modules and configuration (i.e. a cloudflare-managed TLD with an associated cloudflare access key)

## See also

* [cloudflare](https://www.cloudflare.com/)
* [cloudflare TF provider](https://www.terraform.io/docs/providers/cloudflare/r/record.html)

## To do

N/A