provider "kubernetes-alpha" {
  config_path = "/var/vcap/store/k3s-server/kubeconfig.yml" // path to kubeconfig. terraform is colocated with k3s master
  config_context = "default"
}

resource "kubernetes_manifest" "test-configmap" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "v1"
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "test-config"
      "namespace" = "default"
    }
    "data" = {
      "foo" = "bar"
    }
  }
}