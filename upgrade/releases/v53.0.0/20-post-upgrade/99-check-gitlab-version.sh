#!/usr/bin/env bash

CONFIG_DIR=$1


unset https_proxy # We disable proxy to be able to reach k8s server
unset http_proxy # We disable proxy to be ablre to reach k8s server
k8s_cluster_configs="/kubeconfigs/01-ci-k8s"
status=0
for kubeconf in $k8s_cluster_configs;do
  echo "  Credhub key found: <$kubeconf>"
  cluster_name="$(echo $kubeconf|cut -d'/' -f3)"
  echo "  Extracting kubeconfig for cluster $cluster_name"
  credhub g -n "$kubeconf" -q >"${cluster_name}.config" 2>/dev/null
  chmod 700 "${cluster_name}.config"
done
echo "============"
for kubeconfig_file in $(find . -maxdepth 1 -name "*.config"|cut -c3-);do
  expect_gitlab_chart="gitlab-4.12.3"
  gitlab_chart="$(helm list --kubeconfig $kubeconfig_file -n gitlab  --output json 2>/dev/null|jq -r '.[]|select(.name=="gitlab")|.chart')"
  if [ "$expect_gitlab_chart" = "$gitlab_chart" ]; then
    echo "Gitlab k8s ($kubeconfig_file) runs expected version (ie '$expect_gitlab_chart')"
  else
    printf "%bERROR: Gitlab k8s ($kubeconfig_file) expected version is '$expect_gitlab_chart'. But currently running '$gitlab_chart'%b\n" "${RED}${BOLD}" "${STD}"
    status=1
  fi
done
exit $status
