# Coa k3s broker

## Overview

The purpose of this deployment is to provision dedicated kubertetes k3s services 

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | CfApp |
| Depends on | [COAB](https://github.com/orange-cloudfoundry/cf-ops-automation-broker) |
| Vars files | NA |
| Ops files | NA |

## Architecture

The broker is a Spring Boot application written in Java. It commits in git (paas-templates/paas-secrets) bosh manifest artefacts, and scans the result in paas-secrets (output manifest file). 
