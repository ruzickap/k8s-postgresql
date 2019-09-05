terraform {
  required_version = ">= 0.12.8"

  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  # Login credential should be given to this provides by environment variables: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
  version = ">=1.33.1"
}

provider "helm" {
  kubernetes {
    config_path = local_file.file.filename
  }
}

provider "kubernetes" {
  config_path = local_file.file.filename
}

module "k8s_initial_config" {
  source = "../modules/k8s_initial_config"

  client_id                 = var.client_id
  client_secret             = var.client_secret
  cloud_platform            = var.cloud_platform
  dns_zone_name             = var.dns_zone_name
  helm_cert-manager_version = var.helm_cert-manager_version
  helm_external-dns_version = var.helm_external-dns_version
  helm_istio_version        = var.helm_istio_version
  helm_kubed_version        = var.helm_kubed_version
  kubeconfig                = local_file.file.filename
  kubernetes_cluster_name   = var.kubernetes_cluster_name
  letsencrypt_environment   = var.letsencrypt_environment
  prefix                    = var.prefix
  resource_group_name       = var.resource_group_name
  subscription_id           = var.subscription_id
  tenant_id                 = var.tenant_id
}
