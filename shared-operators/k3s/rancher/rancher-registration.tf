#vars
variable "deployment_name" {}
variable "rancher_access_key" {}
variable "rancher_secret_key" {}
variable "ops_domain" {}
variable "intranet_ca" {}


# rancher 2 provider, using access and secret key

provider "rancher2" {
api_url   = "https://rancher-micro.${var.ops_domain}/v3"
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
  ca_certs  = var.intranet_ca
}

# Create a new rancher2 imported Cluster. This exports cluster_registration_token 
resource "rancher2_cluster" "cluster-import" {
  name = var.deployment_name
  description = "imported cluster"
}

# kubernetes provider to apply the registration

provider "kubernetes" {
  config_context = "default"
  config_path = "/var/vcap/store/k3s-server/kubeconfig.yml"
}



