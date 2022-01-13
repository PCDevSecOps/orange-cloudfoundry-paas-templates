
# Create a new Rancher2 App V2 using
# default path is on bosh peristent disk
# kubelet root dir is on k3s bosh release agent kubelet location
resource "rancher2_app_v2" "tf-app-longhorn" {
  cluster_id = data.rancher2_cluster.cluster.id
  name = "longhorn"
  namespace = "longhorn-system"
  repo_name = "rancher-charts"
  chart_name = "longhorn"
  chart_version = "1.1.100"
  values = <<-EOT
  defaultSettings:
    defaultDataPath: /var/vcap/store/longhorn/
  csi:
    kubeletRootDir: /var/vcap/data/k3s-agent/kubelet
  
  EOT
}

