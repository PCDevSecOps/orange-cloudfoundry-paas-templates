terraform {
  required_providers {
    
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.4.0"
    }
    
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.37.0 "
    }
    
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = "1.18.1"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      version = "1.24.3"
    }
    
    nsxt = {
      source = "vmware/nsxt"
      version = "3.1.1"
    }
    
    
    google = {
      source = "hashicorp/google"
      version = "3.56.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.18.0"
    }
    
    cloudfoundry = {
      source = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
    
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.0.2"
    }
    
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.2.1"
    }
    
    helm = {
      source = "hashicorp/helm"
      version = "2.0.2"
    }
    
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.11.0"
    }
    
  }
}

