# gitlab deployment

## Overview

The purpose of this deployment is to instantiate kubernetes object and helm chart into the cluster

## Summary sheet


| namespace | product(s) | comment |
|:---|:---|:---|
|kube-system|core-dns, dashboard, metric-server||
|openebs|openebs| provide cstor and localPv storage class, installed only on persistent worker|
|traefik|traefik| ingress controller|
|monitoring|prometheus, grafana, kube-ops-view ||
|kube-logging|kibana, elasticsearch, fluentd-elasticsearch,falco| tools for logging and auditing K8S cluster|
|weave|wavescope| cannot be move |
|gitlab|gitlab, redis-ha, postgresql, minio| minio need at least 4 nodes|
|concourse|concourse||
|concourse-main| | ns dedicated to secret for main team of concourse|
|backup|velero, shield server+vault |tools dedicated for backup and restore|


