data "rancher2_cluster" "cluster" {
  name = var.deployment_name #cluster name is rancher matches bosh-deployment name
}


# Create a new Rancher2 App V2 using
resource "rancher2_app_v2" "tf-app-monitoring" {
  cluster_id = data.rancher2_cluster.cluster.id
  name = "rancher-monitoring"
  namespace = "cattle-monitoring-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-monitoring"
  chart_version = "14.5.100"
  values = <<-EOT
  prometheus-node-exporter:
    hostRootFsMount: false
  EOT
}

# Create a new Rancher2 App V2 using
resource "rancher2_app_v2" "tf-app-logging" {
  cluster_id = data.rancher2_cluster.cluster.id
  name = "rancher-logging"
  namespace = "cattle-logging-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-logging"
  chart_version = "3.9.400"
}