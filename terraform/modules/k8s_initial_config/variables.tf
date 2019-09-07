variable "accesskeyid" {
  default = "none"
}

variable "client_id" {
  default = "none"
}

variable "client_secret" {
  default = "none"
}

variable "cloud_platform" {
  default = "azure"
}

variable "dns_zone_name" {
  default = "myexample.dev"
}

variable "helm_cert-manager_version" {
  default = "v0.10.0"
}

variable "helm_external-dns_version" {
  default = "2.5.6"
}

variable "helm_istio_version" {
  default = "1.2.5"
}

variable "helm_kubed_version" {
  default = "0.10.0"
}

variable "kubeconfig" {}

variable "full_kubernetes_cluster_name" {
  default     = "k8s-mytest"
}

variable "letsencrypt_environment" {
  default = "staging"
}

variable "prefix" {
  default = "mytest"
}

variable "resource_group_name" {
  default = "terraform_resource_group_name"
}

variable "secret_access_key" {
  default = "none"
}

variable "subscription_id" {
  default = "none"
}

variable "tenant_id" {
  default = "none"
}
