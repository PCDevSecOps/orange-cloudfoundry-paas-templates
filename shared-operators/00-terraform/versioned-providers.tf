terraform {
  required_providers {
    
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.3.0"
    }
    
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.34.1"
    }
    
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = "1.17.0"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      version = "1.24.0"
    }
    
    nsxt = {
      source = "vmware/nsxt"
      version = "3.1.1"
    }
    
    
    google = {
      source = "hashicorp/google"
      version = "3.52.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.17.0"
    }
    
    cloudfoundry = {
      source = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
    
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.2.1"
    }
    
    helm = {
      source = "hashicorp/helm"
      version = "1.3.1"
    }
    
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.10.6"
    }
    
  }
}

