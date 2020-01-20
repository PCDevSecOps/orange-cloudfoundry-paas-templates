#!/bin/sh
credhub delete --name="/bosh-kubo/cfcr/tls-kubernetes-dashboard"
credhub delete --name="/bosh-kubo/cfcr/kubernetes-dashboard-ca"
credhub delete --name="/bosh-kubo/cfcr/tls-influxdb"
credhub delete --name="/bosh-kubo/cfcr/tls-heapster"
credhub delete --name="/bosh-kubo/cfcr/tls-etcdctl"
credhub delete --name="/bosh-kubo/cfcr/tls-etcd"
credhub delete --name="/bosh-kubo/cfcr/tls-docker"
credhub delete --name="/bosh-kubo/cfcr/service-account-key"
credhub delete --name="/bosh-kubo/cfcr/tls-kubernetes"
credhub delete --name="/bosh-kubo/cfcr/tls-kubelet"
credhub delete --name="/bosh-kubo/cfcr/kubo_ca"
credhub delete --name="/bosh-kubo/cfcr/route-sync-password"
credhub delete --name="/bosh-kubo/cfcr/kube-scheduler-password"
credhub delete --name="/bosh-kubo/cfcr/kube-controller-manager-password"
credhub delete --name="/bosh-kubo/cfcr/kube-proxy-password"
credhub delete --name="/bosh-kubo/cfcr/kubelet-drain-password"
credhub delete --name="/bosh-kubo/cfcr/kubelet-password"
credhub delete --name="/bosh-kubo/cfcr/kubo-admin-password"
